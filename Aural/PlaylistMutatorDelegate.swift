import Foundation

class PlaylistMutatorDelegate: PlaylistMutatorDelegateProtocol, MessageSubscriber {
    
    private let playlist: PlaylistCRUDProtocol
    private let playbackSequence: PlaybackSequence
    private let changeListeners: [PlaylistChangeListener]
    
    private let player: BasicPlaybackDelegateProtocol
    
    private let playlistState: PlaylistState
    private let preferences: Preferences
    
    init(_ playlist: PlaylistCRUDProtocol, _ playbackSequence: PlaybackSequence, _ player: BasicPlaybackDelegateProtocol, _ playlistState: PlaylistState, _ preferences: Preferences, _ changeListeners: [PlaylistChangeListener]) {
        
        self.playlist = playlist
        self.playbackSequence = playbackSequence
        
        self.player = player
        
        self.playlistState = playlistState
        self.preferences = preferences
        
        self.changeListeners = changeListeners
        
        SyncMessenger.subscribe(.appLoadedNotification, subscriber: self)
        SyncMessenger.subscribe(.appReopenedNotification, subscriber: self)
    }
    
    func addFiles(_ files: [URL]) {
        
        let autoplay: Bool = self.preferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = self.preferences.autoplayAfterAddingOption == .always
        
        addFiles(files, AutoplayOptions(autoplay, interruptPlayback))
    }
    
    private func addFiles(_ files: [URL], _ autoplayOptions: AutoplayOptions) {
        
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
    
    // Adds a bunch of files synchronously
    // The autoplay argument indicates whether or not autoplay is enabled. Make sure to pass it into functions that call back here recursively (addPlaylist() or addDirectory()).
    // The autoplayed argument indicates whether or not autoplay, if enabled, has already been executed. This value is passed by reference so that recursive calls back here will all see the same value.
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
                    
                    if (AppConstants.supportedPlaylistFileTypes.contains(fileExtension)) {
                        
                        // Playlist
                        addPlaylist(file, autoplayOptions, progress)
                        
                    } else if (AppConstants.supportedAudioFileTypes.contains(fileExtension)) {
                        
                        // Track
                        do {
                            
                            progress.tracksAdded += 1
                            
                            let AsyncMessageProgress = TrackAddedAsyncMessageProgress(progress.tracksAdded, progress.totalTracks)
                            let index = try addTrack(file, AsyncMessageProgress)
                            
                            if (autoplayOptions.autoplay && !progress.autoplayed && index >= 0) {
                                
                                self.autoplay(index, autoplayOptions.interruptPlayback)
                                progress.autoplayed = true
                            }
                            
                        }  catch let error as Error {
                            
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
    
    private func addPlaylist(_ playlistFile: URL, _ autoplayOptions: AutoplayOptions, _ progress: TrackAddOperationProgress) {
        
        let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile)
        if (loadedPlaylist != nil) {
            
            progress.totalTracks -= 1
            progress.totalTracks += (loadedPlaylist?.tracks.count)!
            
            addFiles_sync(loadedPlaylist!.tracks, autoplayOptions, progress)
        }
    }
    
    private func addDirectory(_ dir: URL, _ autoplayOptions: AutoplayOptions, _ progress: TrackAddOperationProgress) {
        
        let dirContents = FileSystemUtils.getContentsOfDirectory(dir)
        if (dirContents != nil) {
            
            progress.totalTracks -= 1
            progress.totalTracks += (dirContents?.count)!
            
            // Add them
            addFiles_sync(dirContents!, autoplayOptions, progress)
        }
    }
    
    // Returns index of newly added track
    private func addTrack(_ file: URL, _ progress: TrackAddedAsyncMessageProgress) throws -> Int {
        
        let track = Track(file)
        let index = playlist.addTrack(track)
        
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
        
        changeListeners.forEach({$0.trackAdded()})
    }
    
    private func autoplay(_ index: Int, _ interruptPlayback: Bool) {
        
        DispatchQueue.main.async {
            
            do {
                
                let playingTrack = try self.player.play(index, interruptPlayback)
                
                // Notify the UI that a track has started playing
                if(playingTrack != nil) {
                    AsyncMessenger.publishMessage(TrackChangedAsyncMessage(playingTrack))
                }
                
            } catch let error as Error {
                
                if (error is InvalidTrackError) {
                    AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(error as! InvalidTrackError))
                }
            }
        }
    }
    
    func removeTrack(_ index: Int) {
        
        playlist.removeTrack(index)
        changeListeners.forEach({$0.trackRemoved(index)})
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
                addFiles(filesToOpen, AutoplayOptions(true, true))
                
            } else if (preferences.playlistOnStartup == .rememberFromLastAppLaunch) {
                
                // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
                addFiles(playlistState.tracks, AutoplayOptions(preferences.autoplayOnStartup, true))
            }
            
            return
        }
        
        if (notification is AppReopenedNotification) {
            
            let msg = notification as! AppReopenedNotification
            
            // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
            addFiles(msg.filesToOpen, AutoplayOptions(!msg.isDuplicateNotification, true))
            
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

class AutoplayOptions {
    
    var autoplay: Bool
    var interruptPlayback: Bool
    
    init(_ autoplay: Bool,
         _ interruptPlayback: Bool) {
        
        self.autoplay = autoplay
        self.interruptPlayback = interruptPlayback
    }
}
