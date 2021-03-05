import Foundation

class TrackReader {
    
    private var fileReader: FileReader
    
    init(_ fileReader: FileReader) {
        self.fileReader = fileReader
    }
    
    func loadPlaylistMetadata(for track: Track) {
        
        let fileMetadata = FileMetadata()
        
        do {
            
            fileMetadata.playlist = try fileReader.getPlaylistMetadata(for: track.file)
            
        } catch {
            
            fileMetadata.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
        }
        
        track.setPlaylistMetadata(from: fileMetadata)
    }
    
    func computePlaybackContext(for track: Track) throws {
        track.playbackContext = try fileReader.getPlaybackMetadata(for: track.file)
        // TODO: If duration has changed as a result of precise computation, set it in the track and send out an update notification
    }
    
    func prepareForPlayback(track: Track) throws {
        
        if let theContext = track.playbackContext {
            try theContext.open()
            
        } else {
            
            try computePlaybackContext(for: track)
            try track.playbackContext?.open()
            
            loadArtAsync(for: track)
        }
    }
    
    func loadArtAsync(for track: Track) {
        
        if track.art == nil {
            
            // Load art async, and send out an update notification if art was found.
            DispatchQueue.global(qos: .userInteractive).async {
                
                track.art = self.fileReader.getArt(for: track.file)
                
                if track.art != nil {
                    Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
                }
            }
        }
    }
    
    func loadAuxiliaryMetadata(for track: Track) {
        
    }
    
    func loadAllMetadata() {
    }
    
    func loadFileSystemInfo(_ track: Track) {
        
        let attrs = FileSystemUtils.fileAttributes(path: track.file.path)
        
        // Filesystem info
        track.fileSize = attrs.size
        track.fileCreationDate = attrs.creationDate
        track.fileLastModifiedDate = attrs.lastModified
        track.fileLastOpenedDate = attrs.lastOpened
    }
}
