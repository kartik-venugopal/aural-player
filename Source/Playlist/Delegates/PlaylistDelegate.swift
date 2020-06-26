import Foundation

class PlaylistDelegate: PlaylistDelegateProtocol, NotificationSubscriber {
    
    // The actual playlist
    private let playlist: PlaylistCRUDProtocol
    
    // The actual playback sequence
    private let sequencer: SequencerProtocol
    
    // A set of all observers/listeners that are interested in changes to the playlist
    private let changeListeners: [PlaylistChangeListenerProtocol]
    
    // A player with basic playback functionality (used for autoplay)
    private let player: PlaybackDelegateProtocol
    
    // Persistent playlist state (used upon app startup)
    private let playlistState: PlaylistState
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private var addSession: TrackAddSession!
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    var isBeingModified: Bool {addSession != nil}
    
    var tracks: [Track] {return playlist.tracks}
    
    var size: Int {return playlist.size}
    
    var duration: Double {return playlist.duration}
    
    // NOTE - Circular dependencies
    
    // TODO: Remove player dependency and send playback command instead.
    
    // TODO: Remove the sequencer dependency from here.
    // Don't send playingTrackRemoved info to changeListeners.
    // Let player figure out if playing track was removed.
    
    // Finally, see if change listeners can be replaced with sync messages
    
    init(_ playlist: PlaylistCRUDProtocol, _ sequencer: SequencerProtocol, _ player: PlaybackDelegateProtocol, _ playlistState: PlaylistState, _ preferences: Preferences, _ changeListeners: [PlaylistChangeListenerProtocol]) {
        
        self.playlist = playlist
        self.sequencer = sequencer
        
        self.player = player
        
        self.playlistState = playlistState
        self.preferences = preferences
        
        self.changeListeners = changeListeners
        
        trackAddQueue.maxConcurrentOperationCount = concurrentAddOpCount
        
        trackAddQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        trackAddQueue.qualityOfService = .userInteractive
        
        trackUpdateQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackUpdateQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        trackUpdateQueue.qualityOfService = .utility
        
        // Subscribe to notifications
        Messenger.subscribe(self, .application_launched, self.appLaunched(_:))
        Messenger.subscribe(self, .application_reopened, self.appReopened(_:))
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return playlist.indexOfTrack(track)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return playlist.trackAtIndex(index)
    }
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        return playlist.summary(playlistType)
    }
    
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        return playlist.search(searchQuery, playlistType)
    }
    
    func groupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack? {
        return playlist.groupingInfoForTrack(groupType, track)
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        return playlist.displayNameForTrack(playlistType, track)
    }
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group? {
        return playlist.groupAtIndex(type, index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack? {
        return playlist.groupingInfoForTrack(type, track)
    }
    
    func indexOfGroup(_ group: Group) -> Int? {
        return playlist.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return playlist.numberOfGroups(type)
    }
    
    func allGroups(_ type: GroupType) -> [Group] {
        return playlist.allGroups(type)
    }
    
    func getGapsAroundTrack(_ track: Track) -> (hasGaps: Bool, beforeTrack: PlaybackGap?, afterTrack: PlaybackGap?) {
        
        let before = getGapBeforeTrack(track)
        let after = getGapAfterTrack(track)
        
        return (before != nil || after != nil, before, after)
    }
    
    func getGapBeforeTrack(_ track: Track) -> PlaybackGap? {
        return playlist.getGapBeforeTrack(track)
    }
    
    func getGapAfterTrack(_ track: Track) -> PlaybackGap? {
        return playlist.getGapAfterTrack(track)
    }
    
    func findFile(_ file: URL) -> Track? {
        return playlist.findTrackByFile(file)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
    
    // MARK: Playlist mutation functions --------------------------------------------------
    
    func addFiles(_ files: [URL]) {
        
        let autoplay: Bool = preferences.playbackPreferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = preferences.playbackPreferences.autoplayAfterAddingOption == .always
        
        addFiles_async(files, AutoplayOptions(autoplay, .playSpecificTrack, interruptPlayback))
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ autoplayOptions: AutoplayOptions, _ userAction: Bool = true) {
        
        addSession = TrackAddSession(files.count, autoplayOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            Messenger.publish(.playlist_startedAddingTracks)
            
            self.collectTracks(files, false)
            self.addSessionTracks()
            
            // ------------------ NOTIFY ------------------
            
            let atLeastOneTrackAdded: Bool = !self.addSession.tracks.isEmpty
            let results = self.addSession.progress.results
            
            if atLeastOneTrackAdded {

                if userAction {
                    Messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
                }
                
                // Notify change listeners
                self.changeListeners.forEach({$0.tracksAdded(results)})
            }
            
            Messenger.publish(.playlist_doneAddingTracks)
            
            // If errors > 0, send AsyncMessage to UI
            // TODO: Display a non-intrusive popover instead of annoying alert (error details optional "Click for more details")
            if !self.addSession.progress.errors.isEmpty {
                Messenger.publish(.playlist_tracksNotAdded, payload: self.addSession.progress.errors)
            }
            
            self.addSession = nil

            // ------------------ UPDATE --------------------
            
            if atLeastOneTrackAdded {
                
                for result in results {
                    
                    self.trackUpdateQueue.addOperation {
                        TrackIO.loadSecondaryInfo(result.track)
                    }
                }
            }
        }
    }
    
    /*
        Adds a bunch of files synchronously.
     
        The autoplayOptions argument encapsulates all autoplay options.
     
        The progress argument indicates current progress.
     */
    private func collectTracks(_ files: [URL], _ isRecursiveCall: Bool) {
        
        if (files.count > 0) {
            
            for _file in files {
                
                // Playlists might contain broken file references
                if (!FileSystemUtils.fileExists(_file)) {
                    addSession.progress.errors.append(FileNotFoundError(_file))
                    continue
                }
                
                // Always resolve sym links and aliases before reading the file
                let resolvedFileInfo = FileSystemUtils.resolveTruePath(_file)
                let file = resolvedFileInfo.resolvedURL
                
                if (resolvedFileInfo.isDirectory) {
                    
                    if !isRecursiveCall {addSession.addedItems.append(file)}
                    
                    // Directory
                    expandDirectory(file)
                    
                } else {
                    
                    // Single file - playlist or track
                    let fileExtension = file.pathExtension.lowercased()
                    
                    if (AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)) {
                        
                        if !isRecursiveCall {addSession.addedItems.append(file)}
                        
                        // Playlist
                        expandPlaylist(file)
                        
                        
                    } else if (AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension)) {
                        
                        // Track
                        
                        let track = Track(file)
                        
                        if !playlist.hasTrack(track) {
                            
                            addSession.tracks.append(track)
                            if !isRecursiveCall {addSession.addedItems.append(file)}
                        }
                    }
                }
            }
        }
    }
    
    // Expands a playlist into individual tracks
    private func expandPlaylist(_ playlistFile: URL) {
        
        let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile)
        if (loadedPlaylist != nil) {
            
            addSession.progress.totalTracks -= 1
            addSession.progress.totalTracks += (loadedPlaylist?.tracks.count)!
            
            collectTracks(loadedPlaylist!.tracks, true)
        }
    }
    
    // Expands a directory into individual tracks (and subdirectories)
    private func expandDirectory(_ dir: URL) {
        
        let dirContents = FileSystemUtils.getContentsOfDirectory(dir)
        if (dirContents != nil) {
            
            addSession.progress.totalTracks -= 1
            addSession.progress.totalTracks += (dirContents?.count)!
            
            collectTracks(dirContents!, true)
        }
    }
    
    private func addSessionTracks() {
        
        if addSession.tracks.isEmpty {return}
        
        var firstIndex: Int = 0
        while addSession.processed < addSession.tracks.count {
            
            let remainingTracks = addSession.tracks.count - addSession.processed
            let lastIndex = firstIndex + min(remainingTracks, concurrentAddOpCount) - 1
            
            let batch = AddBatch()
            batch.indexes = firstIndex...lastIndex
            
            processBatch(batch)
            addSession.processed += batch.indexes.count
            firstIndex = lastIndex + 1
        }
    }
    
    private func processBatch(_ batch: AddBatch) {
        
        // TODO: Use batch.indexes.map {}, addOperations(), and wait until finished in one go
        for index in batch.indexes {
            
            trackAddQueue.addOperation {
                TrackIO.loadPrimaryInfo(self.addSession.tracks[index])
            }
        }
        
        trackAddQueue.waitUntilAllOperationsAreFinished()
        
        for batchIndex in batch.indexes {
            
            let track = addSession.tracks[batchIndex]
            
            if let result = self.playlist.addTrack(track) {
                
                // Add gaps around this track (persistent ones)
                let gapsForTrack = self.playlistState.getGapsForTrack(track)
                self.playlist.setGapsForTrack(track, self.convertGapStateToGap(gapsForTrack.gapBeforeTrack), self.convertGapStateToGap(gapsForTrack.gapAfterTrack))
                self.playlistState.removeGapsForTrack(track)    // TODO: Better way to do this ? App state is only to be used at app startup, not for subsequent calls to addTrack()
                
                addSession.progress.tracksAdded += 1
                addSession.progress.results.append(result)
                
                let progressMsg = TrackAddOperationProgressNotification(addSession.progress.tracksAdded, addSession.progress.totalTracks)
                let trackAddedNotification = TrackAddedNotification(trackIndex: result.flatPlaylistResult, groupingInfo: result.groupingPlaylistResults, addOperationProgress: progressMsg)
                
                Messenger.publish(trackAddedNotification)
                
                if batchIndex == 0 && addSession.autoplayOptions.autoplay {
                    autoplay(addSession.autoplayOptions.autoplayType, result.track, addSession.autoplayOptions.interruptPlayback)
                }
            }
        }
    }
    
    // TODO: If not found, and need to add, simply call the above func add()
    func findOrAddFile(_ file: URL) throws -> Track? {
        
        // Always resolve sym links and aliases before reading the file
        let resolvedFile = FileSystemUtils.resolveTruePath(file).resolvedURL
        
        // If track exists, return it
        if let foundTrack = playlist.findTrackByFile(resolvedFile) {
            return foundTrack
        }
        
        // Track doesn't exist, need to add it
        
        // If the file points to an invalid location, throw an error
        if (!FileSystemUtils.fileExists(resolvedFile)) {
            throw FileNotFoundError(resolvedFile)
        }
        
        // Load display info
        let track = Track(resolvedFile)
        TrackIO.loadPrimaryInfo(track)
        
        // Non-nil result indicates success
        if let result = self.playlist.addTrack(track) {
            
            // Add gaps around this track (persistent ones)
            let gapsForTrack = self.playlistState.getGapsForTrack(track)
            self.playlist.setGapsForTrack(track, self.convertGapStateToGap(gapsForTrack.gapBeforeTrack), self.convertGapStateToGap(gapsForTrack.gapAfterTrack))
            self.playlistState.removeGapsForTrack(track)    // TODO: Better way to do this ? App state is only to be used at app startup, not for subsequent calls to addTrack()
            
            let trackAddedNotification = TrackAddedNotification(trackIndex: result.flatPlaylistResult, groupingInfo: result.groupingPlaylistResults,
                                                      addOperationProgress: TrackAddOperationProgressNotification(1, 1))
            
            Messenger.publish(trackAddedNotification)
            Messenger.publish(.history_itemsAdded, payload: [resolvedFile])
            
            self.changeListeners.forEach({$0.tracksAdded([result])})
            
            TrackIO.loadSecondaryInfo(track)
            return track
        }
        
        return nil
    }
        
    private func convertGapStateToGap(_ gapState: PlaybackGapState?) -> PlaybackGap? {
        
        if gapState == nil {
            return nil
        }
        
        return PlaybackGap(gapState!.duration, gapState!.position, gapState!.type)
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ autoplayType: AutoplayCommandType, _ track: Track, _ interruptPlayback: Bool) {
        
        Messenger.publish(autoplayType == .playSpecificTrack ?
            AutoplayCommandNotification(type: .playSpecificTrack, interruptPlayback: interruptPlayback, candidateTrack: track) :
            AutoplayCommandNotification(type: .beginPlayback))
    }
    
    func removeTracks(_ indexes: IndexSet) {
        
        // TODO: Do the remove on a background thread (maybe if lots are being removed)
        
        let playingTrack: Track? = sequencer.currentTrack
        let indexOfPlayingTrack: Int? = playingTrack == nil ? nil : playlist.indexOfTrack(playingTrack!)
        
        let results: TrackRemovalResults = playlist.removeTracks(indexes)
        
        var playingTrackRemoved: Bool = false
        var removedPlayingTrack: Track? = nil
        
        if let thePlayingTrack = playingTrack, let playingTrackIndex = indexOfPlayingTrack, indexes.contains(playingTrackIndex) {
            
            playingTrackRemoved = true
            removedPlayingTrack = thePlayingTrack
        }
        
        Messenger.publish(TracksRemovedNotification(results: results, playingTrackRemoved: playingTrackRemoved))
        
        changeListeners.forEach({$0.tracksRemoved(results, playingTrackRemoved, removedPlayingTrack)})
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        
        // TODO: Do the remove on a background thread
        
        let playingTrack: Track? = sequencer.currentTrack
        let results = playlist.removeTracksAndGroups(tracks, groups, groupType)
        
        var playingTrackRemoved: Bool = false
        var removedPlayingTrack: Track? = nil
        
        if let thePlayingTrack = playingTrack, playlist.indexOfTrack(thePlayingTrack) == nil {
            
            playingTrackRemoved = true
            removedPlayingTrack = thePlayingTrack
        }
        
        Messenger.publish(TracksRemovedNotification(results: results, playingTrackRemoved: playingTrackRemoved))
        
        changeListeners.forEach({$0.tracksRemoved(results, playingTrackRemoved, removedPlayingTrack)})
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        
        let results = playlist.moveTracksUp(indexes)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults {
        
        let results = playlist.moveTracksToTop(indexes)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        let results = playlist.moveTracksDown(indexes)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults {
        
        let results = playlist.moveTracksToBottom(indexes)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    private func findNewIndexFor(_ oldIndex: Int, _ results: ItemMoveResults) -> Int {
        
        var newIndex: Int = -1
        
        results.results.forEach({
        
            let trackMovedResult = $0 as! TrackMoveResult
            if trackMovedResult.sourceIndex == oldIndex {
                newIndex = trackMovedResult.destinationIndex
            }
        })
        
        return newIndex
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        
        let results = playlist.moveTracksAndGroupsUp(tracks, groups, groupType)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        
        let results = playlist.moveTracksAndGroupsToTop(tracks, groups, groupType)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        let results = playlist.moveTracksAndGroupsDown(tracks, groups, groupType)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        
        let results = playlist.moveTracksAndGroupsToBottom(tracks, groups, groupType)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func clear() {
        
        playlist.clear()
        changeListeners.forEach({$0.playlistCleared()})
    }
    
    func setGapsForTrack(_ track: Track, _ gapBeforeTrack: PlaybackGap?, _ gapAfterTrack: PlaybackGap?) {
        playlist.setGapsForTrack(track, gapBeforeTrack, gapAfterTrack)
    }
    
    func removeGapsForTrack(_ track: Track) {
        playlist.removeGapsForTrack(track)
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) {
        
        let results = playlist.sort(sort, playlistType)
        changeListeners.forEach({$0.playlistSorted(results)})
    }
    
    // MARK: Message handling
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        // Check if any launch parameters were specified
        if !filesToOpen.isEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
            addFiles_async(filesToOpen, AutoplayOptions(true), false)
            
        } else if (preferences.playlistPreferences.playlistOnStartup == .rememberFromLastAppLaunch) {
            
            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
            addFiles_async(playlistState.tracks, AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            
        } else if (preferences.playlistPreferences.playlistOnStartup == .loadFile) {
            
            if let playlistFile: URL = preferences.playlistPreferences.playlistFile {
                addFiles_async([playlistFile], AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            }
            
        } else if (preferences.playlistPreferences.playlistOnStartup == .loadFolder) {
            
            if let folder: URL = preferences.playlistPreferences.tracksFolder {
                addFiles_async([folder], AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            }
        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
        addFiles_async(notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        
        let results = playlist.dropTracks(sourceIndexes, dropIndex)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        let results = playlist.dropTracksAndGroups(tracks, groups, groupType, dropParent, dropIndex)
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
}

// Indicates current progress for an operation that adds tracks to the playlist
class TrackAddOperationProgress {

    var tracksAdded: Int
    var totalTracks: Int
    var results: [TrackAddResult]
    var errors: [DisplayableError]

    init(_ tracksAdded: Int, _ totalTracks: Int, _ results: [TrackAddResult], _ errors: [DisplayableError]) {
        
        self.tracksAdded = tracksAdded
        self.totalTracks = totalTracks
        
        self.results = results
        self.errors = errors
    }
}

// Encapsulates all autoplay options
class AutoplayOptions {
    
    // Whether or not autoplay is requested
    var autoplay: Bool
    
    // Whether or not existing track playback should be interrupted, to perform autoplay
    var interruptPlayback: Bool
    
    // Whether or not the first added track should be selected for playback.
    // If false, the first track in the playlist will play.
    var autoplayType: AutoplayCommandType
    
    init(_ autoplay: Bool,
         _ autoplayType: AutoplayCommandType = .beginPlayback,
         _ interruptPlayback: Bool = true) {
        
        self.autoplay = autoplay
        self.autoplayType = autoplayType
        self.interruptPlayback = interruptPlayback
    }
}

class TrackAddSession {
    
    var tracks: [Track] = []
    var processed: Int = 0
    
    var progress: TrackAddOperationProgress
    var autoplayOptions: AutoplayOptions
    
    var addedItems: [URL] = []

    init(_ numTracks: Int, _ autoplayOptions: AutoplayOptions) {
        
        progress = TrackAddOperationProgress(0, numTracks, [], [])
        self.autoplayOptions = autoplayOptions
    }
}

class AddBatch {
    
    var indexes: ClosedRange<Int> = 0...0
}
