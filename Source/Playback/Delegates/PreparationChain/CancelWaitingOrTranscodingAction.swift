import Foundation

class CancelWaitingOrTranscodingAction: PlaybackPreparationAction {
    
    private let transcoder: TranscoderProtocol
    
    init(_ transcoder: TranscoderProtocol) {
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        // This action should be performed only if the new track was explicitly requested by the user
        // (as opposed to being performed automatically by the player when the previous track completed)
        guard context.requestedByUser else {return true}
        
        if context.currentState == .transcoding, let trackBeingTranscoded = context.currentTrack?.track,
            let newTrack = context.requestedTrack?.track, trackBeingTranscoded != newTrack {
            
            // Don't cancel transcoding if same track will play next (but with different params e.g. delay or start position)
            transcoder.cancel(trackBeingTranscoded)
        }
        
        if context.requestedTrack != nil {
            PlaybackGapContext.clear()
        }
        
        return true
    }
}
