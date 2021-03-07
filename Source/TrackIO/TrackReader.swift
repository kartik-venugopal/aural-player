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
        
        // If duration has changed as a result of precise computation, set it in the track and send out an update notification
        if let playbackContext = track.playbackContext, track.duration != playbackContext.duration {
            
            track.duration = playbackContext.duration
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
        }
    }
    
    func prepareForPlayback(track: Track) throws {
        
        do {
            
            if let theContext = track.playbackContext {
                try theContext.open()
                
            } else {
                
                try computePlaybackContext(for: track)
                try track.playbackContext?.open()
            }
            
            loadArtAsync(for: track)
            
        } catch {
            
            NSLog("Unable to prepare track \(track.displayName) for playback. Error: \(error)")
            
            track.preparationFailed = true
            
            let prepError = TrackNotPlayableError(track.file)
            track.preparationError = prepError
            
            throw prepError
        }
    }
    
    func loadArtAsync(for track: Track) {
        
        if track.artLoaded {return}
        
        // Load art async, and send out an update notification if art was found.
        DispatchQueue.global(qos: .userInteractive).async {
            
            track.art = self.fileReader.getArt(for: track.file)
            
            if track.art != nil {
                Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
            }
        }
    }
    
    func loadArt(for track: Track) {
        
        if track.artLoaded {return}
        
        track.art = self.fileReader.getArt(for: track.file)
        
        if track.art != nil {
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
        }
    }
    
    func loadAuxiliaryMetadata(for track: Track) {
        
        if track.auxMetadataLoaded {return}
        
        let auxMetadata = fileReader.getAuxiliaryMetadata(for: track.file, loadingAudioInfoFrom: track.playbackContext, loadArt: !track.artLoaded)
        track.setAuxiliaryMetadata(auxMetadata)
    }
}
