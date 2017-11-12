import Foundation

/*
    Concrete implementation of PlaylistMutatorDelegateProtocol
 */
class PlaylistMutatorDelegate: PlaylistMutatorDelegateProtocol, MessageSubscriber {
    
    // The actual playlist
    private let playlist: PlaylistCRUDProtocol
    
    // The actual playback sequence
    private let playbackSequencer: PlaybackSequencerProtocol
    
    // A set of all observers/listeners that are interested in changes to the playlist
    private let changeListeners: [PlaylistChangeListenerProtocol]
    
    // A player with basic playback functionality (used for autoplay)
    private let player: BasicPlaybackDelegateProtocol
    
    // Persistent playlist state (used upon app startup)
    private let playlistState: PlaylistState
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    init(_ playlist: PlaylistCRUDProtocol, _ playbackSequencer: PlaybackSequencerProtocol, _ player: BasicPlaybackDelegateProtocol, _ playlistState: PlaylistState, _ preferences: Preferences, _ changeListeners: [PlaylistChangeListenerProtocol]) {
        
        self.playlist = playlist
        self.playbackSequencer = playbackSequencer
        
        self.player = player
        
        self.playlistState = playlistState
        self.preferences = preferences
        
        self.changeListeners = changeListeners
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.appLoadedNotification, .appReopenedNotification], subscriber: self)
    }
    
    func addFiles(_ files: [URL]) {
        
        let autoplay: Bool = self.preferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = self.preferences.autoplayAfterAddingOption == .always
        
        addFiles_async(files, AutoplayOptions(autoplay, interruptPlayback))
        AsyncMessenger.publishMessage(ItemsAddedAsyncMessage(files: files))
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ autoplayOptions: AutoplayOptions) {
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // Progress
            let progress = TrackAddOperationProgress(0, files.count, [TrackAddResult](), [InvalidTrackError](), false)
            
            AsyncMessenger.publishMessage(StartedAddingTracksAsyncMessage.instance)
            
            self.addFiles_sync(files, autoplayOptions, progress)
            
            AsyncMessenger.publishMessage(DoneAddingTracksAsyncMessage.instance)
            
            // If errors > 0, send AsyncMessage to UI
            if (progress.errors.count > 0) {
                AsyncMessenger.publishMessage(TracksNotAddedAsyncMessage(progress.errors))
            }
            
            // Notify change listeners
            self.changeListeners.forEach({$0.tracksAdded(progress.addResults)})
        }
    }
    
    // Assume file doesn't already exist
    func findOrAddFile(_ file: URL) throws -> IndexedTrack {
        
        if let foundTrack = playlist.findTrackByFile(file) {
            return foundTrack
        }
    
        // Need to add it
        
        if (!FileSystemUtils.fileExists(file)) {
            throw FileNotFoundError(file)
        }
        
        // Always resolve sym links and aliases before reading the file
        let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
        let file = resolvedFileInfo.resolvedURL
        
        let track = Track(file)
        TrackIO.loadDisplayInfo(track)
        
        // Non-nil result indicates success
        let result = playlist.addTrack(track)!
        
        // Inform the UI of the new track
        AsyncMessenger.publishMessage(TrackAddedAsyncMessage.fromTrackAddResult(result, TrackAddedMessageProgress(1, 1)))
        
        // Load duration async
        DispatchQueue.global(qos: .userInitiated).async {
            
            TrackIO.loadDuration(track)
            AsyncMessenger.publishMessage(TrackUpdatedAsyncMessage.fromTrackAddResult(result))
        }
        
        // Notify change listeners
        self.changeListeners.forEach({$0.tracksAdded([result])})
        AsyncMessenger.publishMessage(ItemsAddedAsyncMessage(files: [file]))
        
        return IndexedTrack(track, result.flatPlaylistResult)
    }
    
    /*
        Adds a bunch of files synchronously.
     
        The autoplayOptions argument encapsulates all autoplay options.
     
        The progress argument indicates current progress.
     */
    private func addFiles_sync(_ files: [URL], _ autoplayOptions: AutoplayOptions, _ progress: TrackAddOperationProgress) {
        
        if (files.count > 0) {
            
            for _file in files {
                
                // Playlists might contain broken file references
                if (!FileSystemUtils.fileExists(_file)) {
                    progress.errors.append(FileNotFoundError(_file))
                    continue
                }
                
                // Always resolve sym links and aliases before reading the file
                let resolvedFileInfo = FileSystemUtils.resolveTruePath(_file)
                let file = resolvedFileInfo.resolvedURL
                
                if (resolvedFileInfo.isDirectory) {
                    
                    // Directory
                    addDirectory(file, autoplayOptions, progress)
                    
                } else {
                    
                    // Single file - playlist or track
                    let fileExtension = file.pathExtension.lowercased()
                    
                    if (AppConstants.supportedPlaylistFileExtensions.contains(fileExtension)) {
                        
                        // Playlist
                        addPlaylist(file, autoplayOptions, progress)
                        
                    } else if (AppConstants.supportedAudioFileExtensions.contains(fileExtension)) {
                        
                        // Track
                        progress.tracksAdded += 1
                            
                        let progressMsg = TrackAddedMessageProgress(progress.tracksAdded, progress.totalTracks)
                        
                        if let addResult = addTrack(file, progressMsg) {
                            
                            let index = addResult.flatPlaylistResult
                            if (autoplayOptions.autoplay && !progress.autoplayed) {
                                
                                self.autoplay(index, autoplayOptions.interruptPlayback)
                                progress.autoplayed = true
                            }
                            
                            progress.addResults.append(addResult)
                        }
                    }
                }
            }
        }
    }
    
    // Expands a playlist into individual tracks
    private func addPlaylist(_ playlistFile: URL, _ autoplayOptions: AutoplayOptions, _ progress: TrackAddOperationProgress) {
        
        let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile)
        if (loadedPlaylist != nil) {
            
            progress.totalTracks -= 1
            progress.totalTracks += (loadedPlaylist?.tracks.count)!
            
            addFiles_sync(loadedPlaylist!.tracks, autoplayOptions, progress)
        }
    }
    
    // Expands a directory into individual tracks (and subdirectories)
    private func addDirectory(_ dir: URL, _ autoplayOptions: AutoplayOptions, _ progress: TrackAddOperationProgress) {
        
        let dirContents = FileSystemUtils.getContentsOfDirectory(dir)
        if (dirContents != nil) {
            
            progress.totalTracks -= 1
            progress.totalTracks += (dirContents?.count)!
            
            addFiles_sync(dirContents!, autoplayOptions, progress)
        }
    }
    
    // Adds a single track to the playlist. Returns index of newly added track
    private func addTrack(_ file: URL, _ progress: TrackAddedMessageProgress) -> TrackAddResult? {
        
        let track = Track(file)
        TrackIO.loadDisplayInfo(track)
        
        // Non-nil result indicates success
        if let result = playlist.addTrack(track) {

            // Inform the UI of the new track
            AsyncMessenger.publishMessage(TrackAddedAsyncMessage.fromTrackAddResult(result, progress))
            
            // Load duration async
            DispatchQueue.global(qos: .userInitiated).async {
                
                TrackIO.loadDuration(track)
                AsyncMessenger.publishMessage(TrackUpdatedAsyncMessage.fromTrackAddResult(result))
            }
            
            return result
        }
        
        return nil
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ index: Int, _ interruptPlayback: Bool) {
        
        DispatchQueue.main.async {
            
            let oldTrack = self.playbackSequencer.getPlayingTrack()
            
            do {
                
                let playingTrack = try self.player.play(index, interruptPlayback)
                
                // Notify the UI that a track has started playing
                if (playingTrack != nil) {
                    AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, playingTrack))
                }
                
            } catch let error {
                
                if (error is InvalidTrackError) {
                    AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, error as! InvalidTrackError))
                }
            }
        }
    }
    
    func removeTracks(_ indexes: IndexSet) {
        
        let playingTrack = playbackSequencer.getPlayingTrack()
        let results: TrackRemovalResults = playlist.removeTracks(indexes)
        
        let playingTrackRemoved = playingTrack != nil && indexes.contains(playingTrack!.index)
        
        AsyncMessenger.publishMessage(TracksRemovedAsyncMessage(results, playingTrackRemoved))
        
        changeListeners.forEach({$0.tracksRemoved(results, playingTrackRemoved)})
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        
        let playingTrack = playbackSequencer.getPlayingTrack()
        let results = playlist.removeTracksAndGroups(tracks, groups, groupType)
        
        let playingTrackRemoved = playingTrack != nil && playlist.indexOfTrack(playingTrack!.track) == nil
        
        AsyncMessenger.publishMessage(TracksRemovedAsyncMessage(results, playingTrackRemoved))
        
        changeListeners.forEach({$0.tracksRemoved(results, playingTrackRemoved)})
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        let results = playlist.moveTracksUp(indexes)
        changeListeners.forEach({$0.tracksReordered(.tracks)})
        return results
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        let results = playlist.moveTracksDown(indexes)
        changeListeners.forEach({$0.tracksReordered(.tracks)})
        return results
    }
    
    private func findNewIndexFor(_ oldIndex: Int, _ results: ItemMoveResults) -> Int {
        
        var newIndex: Int = -1
        
        results.results.forEach({
        
            let trackMovedResult = $0 as! TrackMoveResult
            if trackMovedResult.oldTrackIndex == oldIndex {
                newIndex = trackMovedResult.newTrackIndex
            }
        })
        
        return newIndex
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        let results = playlist.moveTracksAndGroupsUp(tracks, groups, groupType)
        changeListeners.forEach({$0.tracksReordered(groupType.toPlaylistType())})
        return results
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        let results = playlist.moveTracksAndGroupsDown(tracks, groups, groupType)
        changeListeners.forEach({$0.tracksReordered(groupType.toPlaylistType())})
        return results
    }
    
    func clear() {
        
        playlist.clear()
        changeListeners.forEach({$0.playlistCleared()})
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) {
        
        playlist.sort(sort, playlistType)
        changeListeners.forEach({$0.playlistReordered(playlistType)})
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is AppLoadedNotification) {
            
            let msg = notification as! AppLoadedNotification
            let filesToOpen = msg.filesToOpen
            
            // Check if any launch parameters were specified
            if (!filesToOpen.isEmpty) {
                
                // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
                addFiles_async(filesToOpen, AutoplayOptions(true, true))
                
            } else if (preferences.playlistOnStartup == .rememberFromLastAppLaunch) {
                
                // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
                addFiles_async(playlistState.tracks, AutoplayOptions(preferences.autoplayOnStartup, true))
            }
            
            return
        }
        
        if (notification is AppReopenedNotification) {
            
            let msg = notification as! AppReopenedNotification
            
            // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
            addFiles_async(msg.filesToOpen, AutoplayOptions(!msg.isDuplicateNotification, true))
            
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet {
        
        let destination = playlist.dropTracks(sourceIndexes, dropIndex, dropType)
        changeListeners.forEach({$0.tracksReordered(.tracks)})
        return destination
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        let results = playlist.dropTracksAndGroups(tracks, groups, groupType, dropParent, dropIndex)
        changeListeners.forEach({$0.tracksReordered(groupType.toPlaylistType())})
        return results
    }
}

// Indicates current progress for an operation that adds tracks to the playlist
class TrackAddOperationProgress {

    var tracksAdded: Int
    var totalTracks: Int
    var addResults: [TrackAddResult]
    var errors: [InvalidTrackError]
    var autoplayed: Bool

    init(_ tracksAdded: Int, _ totalTracks: Int, _ addResults: [TrackAddResult], _ errors: [InvalidTrackError], _ autoplayed: Bool) {
        
        self.tracksAdded = tracksAdded
        self.totalTracks = totalTracks
        
        self.addResults = addResults
        self.errors = errors
        self.autoplayed = autoplayed
    }
}

// Encapsulates all autoplay options
class AutoplayOptions {
    
    // Whether or not autoplay is requested
    var autoplay: Bool
    
    // Whether or not existing track playback should be interrupted, to perform autoplay
    var interruptPlayback: Bool
    
    init(_ autoplay: Bool,
         _ interruptPlayback: Bool) {
        
        self.autoplay = autoplay
        self.interruptPlayback = interruptPlayback
    }
}
