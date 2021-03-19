import Foundation

///
/// Handles loading of metadata for a track.
///
class TrackReader {
    
    // The delegate object that this object defers all read operations to.
    private var fileReader: FileReader
    
    init(_ fileReader: FileReader) {
        self.fileReader = fileReader
    }
    
    ///
    /// Loads the essential metadata fields that are required for a track to be loaded into the playlist.
    ///
    func loadPlaylistMetadata(for track: Track) {
        
        let fileMetadata = FileMetadata()
        var durationIsAccurate: Bool = true
        
        do {
            
            let playlistMetadata = try fileReader.getPlaylistMetadata(for: track.file)
            fileMetadata.playlist = playlistMetadata
            
            durationIsAccurate = playlistMetadata.durationIsAccurate
            
        } catch {
            
            fileMetadata.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
        }
        
        track.setPlaylistMetadata(from: fileMetadata)
        
        // For non-native tracks that don't have accurate duration, compute duration async.
        
        if !track.isNativelySupported, track.isPlayable, track.duration <= 0 || !durationIsAccurate {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                if let duration = self.fileReader.computeAccurationDuration(for: track.file), duration > 0 {
                    
                    track.duration = duration
                    track.durationIsAccurate = true
                    
                    Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
                }
            }
        }
    }
    
    private func computePlaybackContext(for track: Track) throws {
        
        track.playbackContext = try fileReader.getPlaybackMetadata(for: track.file)
        
        // If duration has changed as a result of precise computation, set it in the track and send out an update notification
        if !track.durationIsAccurate, let playbackContext = track.playbackContext, track.duration != playbackContext.duration {
            
            track.duration = playbackContext.duration
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
        }
    }
    
    ///
    /// Loads all metadata and resources that are required for track playback.
    ///
    func prepareForPlayback(track: Track) throws {
        
        // Make sure track is valid before trying to prep it for playback.
        if let validationError = track.validationError {
            
            track.preparationError = validationError
            throw validationError
        }
        
        do {
            
            // If a playback context has been previously computed, just open it.
            if let theContext = track.playbackContext {
                try theContext.open()
                
            } else {
                
                // No playback context was previously computed, so compute it and open it.
                
                try computePlaybackContext(for: track)
                try track.playbackContext?.open()
            }
            
            // Load cover art for display in the player.
            loadArtAsync(for: track)
            
        } catch {
            
            NSLog("Unable to prepare track \(track.displayName) for playback. Error: \(error)")
            
            track.preparationFailed = true
            
            if let prepError = error as? DisplayableError {
                track.preparationError = prepError
            }
            
            throw error
        }
    }
    
    ///
    /// Loads cover art for a track, asynchronously. This is useful when
    /// cover art is not required immediately, and a short delay is acceptable.
    /// (eg. when preparing for playback)
    ///
    func loadArtAsync(for track: Track) {
        
        if track.artLoaded {return}
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            track.art = self.fileReader.getArt(for: track.file)

            // Send out an update notification if art was found.
            if track.art != nil {
                Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
            }
        }
    }
    
    ///
    /// Loads cover art for a track.
    ///
    func loadArt(for track: Track) {
        
        if track.artLoaded {return}
        
        track.art = self.fileReader.getArt(for: track.file)
        
        // Send out an update notification if art was found.
        if track.art != nil {
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
        }
    }
    
    ///
    /// Loads all non-essential ("auxiliary") metadata associated with a track, for display in the "Detailed track info" view.
    ///
    func loadAuxiliaryMetadata(for track: Track) {
        
        if track.auxMetadataLoaded {return}
        
        let auxMetadata = fileReader.getAuxiliaryMetadata(for: track.file,
                                                          loadingAudioInfoFrom: track.playbackContext, loadArt: !track.artLoaded)
        track.setAuxiliaryMetadata(auxMetadata)
    }
}
