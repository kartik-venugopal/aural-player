import AVFoundation

class AVFPlaybackContext: PlaybackContextProtocol {
    
    let file: URL
    var audioFile: AVAudioFile!

    let audioFormat: AVAudioFormat
    
    let sampleRate: Double
    let frameCount: AVAudioFramePosition
    let computedDuration: Double
    
    var duration: Double {computedDuration}
    
    init(for file: URL) throws {

        self.file = file
        self.audioFile = try AVAudioFile(forReading: file)

        self.audioFormat = audioFile.processingFormat
        self.sampleRate = audioFormat.sampleRate
        self.frameCount = audioFile.length
        self.computedDuration = Double(frameCount) / sampleRate
        
        try validateFile(file)
    }
    
    private func validateFile(_ file: URL) throws {
        
        // TODO: Test against a protected iTunes file
        
        let asset = AVURLAsset(url: file, options: nil)
        
        if asset.hasProtectedContent {
            throw DRMProtectionError(file)
        }
        
        let assetTracks = asset.tracks(withMediaType: .audio)
        
        // Check if the asset has any audio tracks
        if assetTracks.isEmpty {
            throw NoAudioTracksError(file)
        }
        
        // Find out if track is playable
        // TODO: What does isPlayable actually mean ?
        if let assetTrack = assetTracks.first, !assetTrack.isPlayable {
            throw TrackNotPlayableError(file)
        }
    }
    
    // Called when preparing for playback
    func open() throws {
        
        if audioFile == nil {
            audioFile = try AVAudioFile(forReading: file)
        }
    }
    
    // Called upon completion of playback
    func close() {
        audioFile = nil
    }
    
    deinit {
        close()
    }
}
