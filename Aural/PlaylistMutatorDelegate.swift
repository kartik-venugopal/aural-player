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
    }
    
    // This is called when the app loads initially. Loads the playlist from the app state file on disk. Only meant to be called once.
    private func loadPlaylistFromSavedState() {
        
        // Add tracks async, notifying the UI one at a time
        DispatchQueue.global(qos: .userInteractive).async {
            
            // NOTE - Assume that all entries are valid tracks (supported audio files), not playlists and not directories. i.e. assume that saved state file has not been corrupted.
            
            var errors: [InvalidTrackError] = [InvalidTrackError]()
            let autoplay: Bool = self.preferences.autoplayOnStartup
            var autoplayed: Bool = false
            
            let tracks = self.playlistState.tracks
            let totalTracks = tracks.count
            var tracksAdded = 0
            
            EventRegistry.publishEvent(.startedAddingTracks, StartedAddingTracksEvent.instance)
            
            for trackPath in tracks {
                
                tracksAdded += 1
                
                // Playlist might contain broken file references
                if (!FileSystemUtils.fileExists(trackPath)) {
                    errors.append(FileNotFoundError(URL(fileURLWithPath: trackPath)))
                    continue
                }
                
                let resolvedFileInfo = FileSystemUtils.resolveTruePath(URL(fileURLWithPath: trackPath))
                
                do {
                    
                    let progress = TrackAddedEventProgress(tracksAdded, totalTracks)
                    try self.addTrack(resolvedFileInfo.resolvedURL, progress)
                    
                    if (autoplay && !autoplayed) {
                        self.autoplay(tracksAdded - 1, true)
                        autoplayed = true
                    }
                    
                } catch let error as Error {
                    
                    if (error is InvalidTrackError) {
                        errors.append(error as! InvalidTrackError)
                    }
                }
            }
            
            EventRegistry.publishEvent(.doneAddingTracks, DoneAddingTracksEvent.instance)
            
            // If errors > 0, send event to UI
            if (errors.count > 0) {
                EventRegistry.publishEvent(.tracksNotAdded, TracksNotAddedEvent(errors))
            }
        }
    }
    
    private func autoplay(_ index: Int, _ interruptPlayback: Bool) {
        
        DispatchQueue.main.async {
            
            do {
                
                let playingTrack = try self.player.play(index, interruptPlayback)
                
                // Notify the UI that a track has started playing
                if(playingTrack != nil) {
                    EventRegistry.publishEvent(.trackChanged, TrackChangedEvent(playingTrack))
                }
                
            } catch let error as Error {
                
                if (error is InvalidTrackError) {
                    EventRegistry.publishEvent(.trackNotPlayed, TrackNotPlayedEvent(error as! InvalidTrackError))
                }
            }
        }
    }
    
    func addFiles(_ files: [URL]) {
        
        EventRegistry.publishEvent(.startedAddingTracks, StartedAddingTracksEvent.instance)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            let autoplay: Bool = self.preferences.autoplayAfterAddingTracks
            let interruptPlayback: Bool = self.preferences.autoplayAfterAddingOption == .always
            
            // Progress
            let progress = TrackAddOperationProgress(0, files.count, [InvalidTrackError](), false)
            
            self.addFiles_sync(files, AutoplayOptions(autoplay, interruptPlayback), progress)
            
            EventRegistry.publishEvent(.doneAddingTracks, DoneAddingTracksEvent.instance)
            
            // If errors > 0, send event to UI
            if (progress.errors.count > 0) {
                EventRegistry.publishEvent(.tracksNotAdded, TracksNotAddedEvent(progress.errors))
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
                            
                            let eventProgress = TrackAddedEventProgress(progress.tracksAdded, progress.totalTracks)
                            let index = try addTrack(file, eventProgress)
                            
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
    private func addTrack(_ file: URL, _ progress: TrackAddedEventProgress) throws -> Int {
        
        let track = try TrackIO.loadTrack(file)
        let index = playlist.addTrack(track)
        
        if (index >= 0) {
            notifyTrackAdded(index, progress)
        }
        
        return index
    }
    
    // Publishes a notification that a new track has been added to the playlist
    private func notifyTrackAdded(_ trackIndex: Int, _ progress: TrackAddedEventProgress) {
        
        let trackAddedEvent = TrackAddedEvent(trackIndex, progress)
        EventRegistry.publishEvent(.trackAdded, trackAddedEvent)
        
        for listener in changeListeners {
            listener.trackAdded()
        }
    }
    
    func removeTrack(_ index: Int) {
        
        playlist.removeTrack(index)
        
        for listener in changeListeners {
            listener.trackRemoved(index)
        }
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        
        let newIndex = playlist.moveTrackUp(index)
        if (newIndex != index) {
            for listener in changeListeners {
                listener.trackReordered(index, newIndex)
            }
        }
        
        return newIndex
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        
        let newIndex = playlist.moveTrackDown(index)
        if (newIndex != index) {
            for listener in changeListeners {
                listener.trackReordered(index, newIndex)
            }
        }
        
        return newIndex
    }
    
    func clear() {
        
        playlist.clear()
        
        for listener in changeListeners {
            listener.playlistCleared()
        }
    }
    
    func sort(_ sort: Sort) {
        
        let oldCursor = playbackSequence.getCursor()
        let playingTrack = playlist.peekTrackAt(oldCursor)
        
        playlist.sort(sort)
        
        let newCursor = playlist.indexOfTrack(playingTrack?.track)
        
        for listener in changeListeners {
            listener.playlistReordered(newCursor)
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is AppLoadedNotification
            && preferences.playlistOnStartup == .rememberFromLastAppLaunch) {
            
            loadPlaylistFromSavedState()
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
