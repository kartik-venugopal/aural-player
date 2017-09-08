import Foundation

class PlaylistMutatorDelegate: PlaylistMutatorDelegateProtocol {
    
    private let playlist: PlaylistCRUDProtocol
    private let playbackSequence: PlaybackSequence
    
    init(_ playlist: PlaylistCRUDProtocol, _ playbackSequence: PlaybackSequence) {
        self.playlist = playlist
        self.playbackSequence = playbackSequence
    }
    
    func addFiles(_ files: [URL]) {
        
        if (files.count > 0) {
            
            for _file in files {
                
                // Playlists might contain broken file references
                if (!FileSystemUtils.fileExists(_file)) {
                    continue
                }
                
                // Always resolve sym links and aliases before reading the file
                let resolvedFileInfo = FileSystemUtils.resolveTruePath(_file)
                let file = resolvedFileInfo.resolvedURL
                
                if (resolvedFileInfo.isDirectory) {
                    
                    // Directory
                    addDirectory(file)
                    
                } else {
                    
                    // Single file - playlist or track
                    let fileExtension = file.pathExtension.lowercased()
                    
                    if (AppConstants.supportedPlaylistFileTypes.contains(fileExtension)) {
                        
                        // Playlist
                        addPlaylist(file)
                        
                    } else if (AppConstants.supportedAudioFileTypes.contains(fileExtension)) {
                        
                        // Track
                        do {
                            try addTrack(file)
                            
                            // TODO: Add progress/errors/notification
                            
                        }  catch let error as Error {
                            
                        }
                        
                    } else {
                        
                        // Unsupported file type, ignore
                        NSLog("Ignoring unsupported file: %@", file.path)
                    }
                }
            }
        }
    }
    
    // Returns index of newly added track
    private func addTrack(_ file: URL) throws -> Int {
        
        let track = try TrackIO.loadTrack(file)
        let index = playlist.addTrack(track)
        if (index >= 0) {
            playbackSequence.trackAdded()
        }
        
        return index
    }
    
    private func addPlaylist(_ playlistFile: URL) {
        
        let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile)
        if (loadedPlaylist != nil) {
            addFiles(loadedPlaylist!.tracks)
        }
    }
    
    private func addDirectory(_ dir: URL) {
        
        let dirContents = FileSystemUtils.getContentsOfDirectory(dir)
        if (dirContents != nil) {
            addFiles(dirContents!)
        }
    }
    
    func removeTrack(_ index: Int) {
        playlist.removeTrack(index)
        playbackSequence.trackRemoved(index)
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        
        let newIndex = playlist.moveTrackUp(index)
        if (newIndex != index) {
            playbackSequence.trackReordered(index, newIndex)
        }
        
        return newIndex
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        
        let newIndex = playlist.moveTrackDown(index)
        if (newIndex != index) {
            playbackSequence.trackReordered(index, newIndex)
        }
        
        return newIndex
    }
    
    func clear() {
        playlist.clear()
        playbackSequence.playlistCleared()
    }
    
    func sort(_ sort: Sort) {
        
        let oldCursor = playbackSequence.getCursor()
        let playingTrack = playlist.peekTrackAt(oldCursor)
        
        playlist.sort(sort)
        
        let newCursor = playlist.indexOfTrack(playingTrack?.track)
        playbackSequence.playlistReordered(newCursor)
    }
}
