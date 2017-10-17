import Foundation

/*
    Concrete implementation of PlaylistMutatorDelegateProtocol
 */
class PlaylistMutatorDelegate: PlaylistMutatorDelegateProtocol, MessageSubscriber {
    
    // The actual playlist
    private let playlist: PlaylistCRUDProtocol
    
    // The actual playback sequence
    private let playbackSequence: PlaybackSequence
    
    // A set of all observers/listeners that are interested in changes to the playlist
    private let changeListeners: [PlaylistChangeListener]
    
    // A player with basic playback functionality (used for autoplay)
    private let player: BasicPlaybackDelegateProtocol
    
    // Persistent playlist state (used upon app startup)
    private let playlistState: PlaylistState
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    init(_ playlist: PlaylistCRUDProtocol, _ playbackSequence: PlaybackSequence, _ player: BasicPlaybackDelegateProtocol, _ playlistState: PlaylistState, _ preferences: Preferences, _ changeListeners: [PlaylistChangeListener]) {
        
        self.playlist = playlist
        self.playbackSequence = playbackSequence
        
        self.player = player
        
        self.playlistState = playlistState
        self.preferences = preferences
        
        self.changeListeners = changeListeners
        
        // Subscribe for message notifications
        SyncMessenger.subscribe(.appLoadedNotification, subscriber: self)
        SyncMessenger.subscribe(.appReopenedNotification, subscriber: self)
    }
    
    func addFiles(_ files: [URL]) {
        
        let autoplay: Bool = self.preferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = self.preferences.autoplayAfterAddingOption == .always
        
        addFiles_async(files, AutoplayOptions(autoplay, interruptPlayback))
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ autoplayOptions: AutoplayOptions) {
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // Progress
            let progress = TrackAddOperationProgress(0, files.count, [InvalidTrackError](), false)
            
            AsyncMessenger.publishMessage(StartedAddingTracksAsyncMessage.instance)
            
            self.addFiles_sync(files, autoplayOptions, progress)
            
            AsyncMessenger.publishMessage(DoneAddingTracksAsyncMessage.instance)
            
            // If errors > 0, send AsyncMessage to UI
            if (progress.errors.count > 0) {
                AsyncMessenger.publishMessage(TracksNotAddedAsyncMessage(progress.errors))
            }
        }
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
                        do {
                            
                            progress.tracksAdded += 1
                            
                            let AsyncMessageProgress = TrackAddedAsyncMessageProgress(progress.tracksAdded, progress.totalTracks)
                            let index = try addTrack(file, AsyncMessageProgress)
                            
                            if (autoplayOptions.autoplay && !progress.autoplayed && index >= 0) {
                                
                                self.autoplay(index, autoplayOptions.interruptPlayback)
                                progress.autoplayed = true
                            }
                            
                        }  catch let error {
                            
                            if (error is InvalidTrackError) {
                                progress.errors.append(error as! InvalidTrackError)
                            }
                        }
                        
                    } else {
                        
                        // Unsupported file type, ignore
                        NSLog("Ignoring unsupported file: %@", file.path)
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
            
            // Add them
            addFiles_sync(dirContents!, autoplayOptions, progress)
        }
    }
    
    // Adds a single track to the playlist. Returns index of newly added track
    private func addTrack(_ file: URL, _ progress: TrackAddedAsyncMessageProgress) throws -> Int {
        
        let track = Track(file)
        let index = playlist.addTrack(track)
        
        // index >= 0 indicates success in adding the track to the playlist
        if (index >= 0) {
            
            notifyTrackAdded(index, progress)
            
            // Load display info async (ID3 info, duration)
            DispatchQueue.global(qos: .userInitiated).async {
                TrackIO.loadDisplayInfo(track)
                AsyncMessenger.publishMessage(TrackInfoUpdatedAsyncMessage(index))
            }
        }
        
        return index
    }
    
    // Publishes a notification that a new track has been added to the playlist
    private func notifyTrackAdded(_ trackIndex: Int, _ progress: TrackAddedAsyncMessageProgress) {
        
        let trackAddedAsyncMessage = TrackAddedAsyncMessage(trackIndex, progress)
        AsyncMessenger.publishMessage(trackAddedAsyncMessage)
        
        // Also notify the listeners directly
        changeListeners.forEach({$0.trackAdded()})
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ index: Int, _ interruptPlayback: Bool) {
        
        DispatchQueue.main.async {
            
            let oldCursor = self.playbackSequence.getCursor()
            let oldTrack = self.playlist.peekTrackAt(oldCursor)
            
            do {
                
                let playingTrack = try self.player.play(index, interruptPlayback)
                
                // Notify the UI that a track has started playing
                if(playingTrack != nil) {
                    AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, playingTrack))
                }
                
            } catch let error {
                
                if (error is InvalidTrackError) {
                    AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, error as! InvalidTrackError))
                }
            }
        }
    }
    
    func removeTracks(_ indexes: [Int]) {
        playlist.removeTracks(indexes)
        changeListeners.forEach({$0.tracksRemoved(indexes)})
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        
        let newIndex = playlist.moveTrackUp(index)
        if (newIndex != index) {
            changeListeners.forEach({$0.trackReordered(index, newIndex)})
        }
        
        return newIndex
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        
        let newIndex = playlist.moveTrackDown(index)
        if (newIndex != index) {
            changeListeners.forEach({$0.trackReordered(index, newIndex)})
        }
        
        return newIndex
    }
    
    func clear() {
        
        playlist.clear()
        changeListeners.forEach({$0.playlistCleared()})
    }
    
    func sort(_ sort: Sort) {
        
        let oldCursor = playbackSequence.getCursor()
        let playingTrack = playlist.peekTrackAt(oldCursor)
        
        playlist.sort(sort)
        
        let newCursor = playlist.indexOfTrack(playingTrack?.track)
        changeListeners.forEach({$0.playlistReordered(newCursor)})
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
}

// Indicates current progress for an operation that adds tracks to the playlist
class TrackAddOperationProgress {

    var tracksAdded: Int
    var totalTracks: Int
    var errors: [InvalidTrackError]
    var autoplayed: Bool

    init(_ tracksAdded: Int, _ totalTracks: Int, _ errors: [InvalidTrackError], _ autoplayed: Bool) {
        
        self.tracksAdded = tracksAdded
        self.totalTracks = totalTracks
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
