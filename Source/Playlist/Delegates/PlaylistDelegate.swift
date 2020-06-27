import Foundation

class PlaylistDelegate: PlaylistDelegateProtocol, NotificationSubscriber {
    
    // The actual playlist
    private let playlist: PlaylistCRUDProtocol
    
    // TODO - See if change listeners can be replaced with sync messages
    // A set of all observers/listeners that are interested in changes to the playlist
    private let changeListeners: [PlaylistChangeListenerProtocol]
    
    // Persistent playlist state (used upon app startup)
    private let playlistState: PlaylistState
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private var addSession: TrackAddSession!
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    var isBeingModified: Bool {addSession != nil}
    
    var tracks: [Track] {playlist.tracks}
    
    var size: Int {playlist.size}
    
    var duration: Double {playlist.duration}
    
    init(_ playlist: PlaylistCRUDProtocol, _ playlistState: PlaylistState, _ preferences: Preferences, _ changeListeners: [PlaylistChangeListenerProtocol]) {
        
        self.playlist = playlist
        
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
        
        let gapBefore = getGapBeforeTrack(track)
        let gapAfter = getGapAfterTrack(track)
        
        return (gapBefore != nil || gapAfter != nil, gapBefore, gapAfter)
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
        
        let autoplayEnabled: Bool = preferences.playbackPreferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = preferences.playbackPreferences.autoplayAfterAddingOption == .always
        
        addFiles_async(files, [:], AutoplayOptions(autoplayEnabled, .playSpecificTrack, interruptPlayback))
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ gapsByFile: [URL: (PlaybackGap?, PlaybackGap?)], _ autoplayOptions: AutoplayOptions, _ userAction: Bool = true) {
        
        addSession = TrackAddSession(files.count, autoplayOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            Messenger.publish(.playlist_startedAddingTracks)
            
            self.collectTracks(files, false)
            self.addSessionTracks(gapsByFile)
            
            // ------------------ NOTIFY ------------------
            
            let results = self.addSession.progress.results
            
            if userAction {
                Messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
            }
            
            // Notify change listeners
            self.changeListeners.forEach({$0.tracksAdded(results)})
            
            Messenger.publish(.playlist_doneAddingTracks)
            
            // If errors > 0, send AsyncMessage to UI
            if !self.addSession.progress.errors.isEmpty {
                Messenger.publish(.playlist_tracksNotAdded, payload: self.addSession.progress.errors)
            }
            
            self.addSession = nil
            
            // ------------------ UPDATE --------------------
            
            self.trackUpdateQueue.addOperations(results.map {result in BlockOperation {TrackIO.loadSecondaryInfo(result.track)}},
                                                waitUntilFinished: false)
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
    
    private func addSessionTracks(_ gapsByFile: [URL: (PlaybackGap?, PlaybackGap?)]) {
        
        if addSession.tracks.isEmpty {return}
        
        var firstIndex: Int = 0
        while addSession.processed < addSession.tracks.count {
            
            let remainingTracks = addSession.tracks.count - addSession.processed
            let lastIndex = firstIndex + min(remainingTracks, concurrentAddOpCount) - 1
            
            let batch = AddBatch()
            batch.indexes = firstIndex...lastIndex
            
            processBatch(batch, gapsByFile)
            addSession.processed += batch.indexes.count
            firstIndex = lastIndex + 1
        }
    }
    
    private func processBatch(_ batch: AddBatch, _ gapsByFile: [URL: (gapBeforeTrack: PlaybackGap?, gapAfterTrack: PlaybackGap?)]) {
        
        // Process all tracks in batch concurrently and wait until the entire batch finishes.
        trackAddQueue.addOperations(batch.indexes.map {index in BlockOperation {TrackIO.loadPrimaryInfo(self.addSession.tracks[index])}}, waitUntilFinished: true)
        
        for (batchIndex, track) in zip(batch.indexes, batch.indexes.map {addSession.tracks[$0]}) {
            
            if let result = self.playlist.addTrack(track) {
                
                // Add gaps around this track (persistent ones)
                if let gapsForTrack = gapsByFile[track.file] {
                    self.playlist.setGapsForTrack(track, gapsForTrack.gapBeforeTrack, gapsForTrack.gapAfterTrack)
                }
                
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
    
    // TODO: If not found, and need to add, simply call the above func add() ???
    func findOrAddFile(_ file: URL) throws -> Track? {
        
        // Always resolve sym links and aliases before reading the file
        let resolvedFile = FileSystemUtils.resolveTruePath(file).resolvedURL
        
        // If track exists, return it
        if let foundTrack = playlist.findTrackByFile(resolvedFile) {
            return foundTrack
        }
        
        // Track doesn't exist, need to add it
        
        // If the file points to an invalid location, throw an error
        guard FileSystemUtils.fileExists(resolvedFile) else {throw FileNotFoundError(resolvedFile)}
        
        // Load display info
        let track = Track(resolvedFile)
        TrackIO.loadPrimaryInfo(track)
        
        // Non-nil result indicates success
        guard let result = self.playlist.addTrack(track) else {return nil}
            
        let trackAddedNotification = TrackAddedNotification(trackIndex: result.flatPlaylistResult, groupingInfo: result.groupingPlaylistResults,
                                                            addOperationProgress: TrackAddOperationProgressNotification(1, 1))
        
        Messenger.publish(trackAddedNotification)
        Messenger.publish(.history_itemsAdded, payload: [resolvedFile])
        
        self.changeListeners.forEach({$0.tracksAdded([result])})
        
        TrackIO.loadSecondaryInfo(track)
        return track
    }
        
    private func convertGapStateToGap(_ gapState: PlaybackGapState?) -> PlaybackGap? {
        
        if let theGapState = gapState {
            return PlaybackGap(theGapState.duration, theGapState.position, theGapState.type)
        }
        
        return nil
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ autoplayType: AutoplayCommandType, _ track: Track, _ interruptPlayback: Bool) {
        
        Messenger.publish(autoplayType == .playSpecificTrack ?
            AutoplayCommandNotification(type: .playSpecificTrack, interruptPlayback: interruptPlayback, candidateTrack: track) :
            AutoplayCommandNotification(type: .beginPlayback))
    }
    
    func removeTracks(_ indexes: IndexSet) {
        
        // TODO: Do the remove on a background thread (maybe if lots are being removed)
        
        let results: TrackRemovalResults = playlist.removeTracks(indexes)
        Messenger.publish(.playlist_tracksRemoved, payload: results)
        
        changeListeners.forEach({$0.tracksRemoved(results)})
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        
        // TODO: Do the remove on a background thread
        
        let results = playlist.removeTracksAndGroups(tracks, groups, groupType)
        Messenger.publish(.playlist_tracksRemoved, payload: results)
        
        changeListeners.forEach({$0.tracksRemoved(results)})
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
        
        var gapsByFile: [URL: (PlaybackGap?, PlaybackGap?)] = [:]
        
        for file in Set(playlistState.gaps.compactMap({$0.track})) {
            
            let theGaps = playlistState.getGapsForTrack(file)
            gapsByFile[file] = (convertGapStateToGap(theGaps.gapBeforeTrack), convertGapStateToGap(theGaps.gapAfterTrack))
        }
        
        // Check if any launch parameters were specified
        if !filesToOpen.isEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
            addFiles_async(filesToOpen, [:], AutoplayOptions(true), false)
            
        } else if (preferences.playlistPreferences.playlistOnStartup == .rememberFromLastAppLaunch) {
            
            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
            addFiles_async(playlistState.tracks, gapsByFile, AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            
        } else if (preferences.playlistPreferences.playlistOnStartup == .loadFile), let playlistFile: URL = preferences.playlistPreferences.playlistFile {
            
            addFiles_async([playlistFile], gapsByFile, AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            
        } else if (preferences.playlistPreferences.playlistOnStartup == .loadFolder), let folder: URL = preferences.playlistPreferences.tracksFolder {
            
            addFiles_async([folder], gapsByFile, AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
        addFiles_async(notification.filesToOpen, [:], AutoplayOptions(!notification.isDuplicateNotification))
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
