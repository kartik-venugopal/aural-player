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
        
        let auxMetadata = fileReader.getAuxiliaryMetadata(for: track.file)
        
        // TODO: This should also be done for FFmpeg tracks ... pass bool into getAuxMeta(needToLoadAudioInfo), true if no plbkCtx found.
        // Transfer audio info from playback info, if available
        if track.isNativelySupported, let plbkCtx = track.playbackContext {
            
            let intChannelCount = Int(plbkCtx.audioFormat.channelCount)
            auxMetadata.audioInfo?.numChannels = intChannelCount
            auxMetadata.audioInfo?.channelLayout = channelLayout(intChannelCount)
            
            auxMetadata.audioInfo?.sampleRate = Int32(plbkCtx.sampleRate)
            auxMetadata.audioInfo?.frames = plbkCtx.frameCount
        }
        
        track.setAuxiliaryMetadata(auxMetadata)
    }
    
    private func channelLayout(_ numChannels: Int) -> String {
        
        switch numChannels {
            
        case 1: return "Mono (1 ch)"
            
        case 2: return "Stereo (2 ch)"
            
        case 6: return "5.1 (6 ch)"
            
        case 8: return "7.1 (8 ch)"
            
        case 10: return "9.1 (10 ch)"
            
        default: return String(format: "%d channels", numChannels)
            
        }
    }
    
    func loadAllMetadata() {
        // TODO
    }
}
