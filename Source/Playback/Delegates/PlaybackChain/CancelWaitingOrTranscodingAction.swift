import Foundation

class CancelWaitingOrTranscodingAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
    private let transcoder: TranscoderProtocol
    
    init(_ transcoder: TranscoderProtocol) {
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        // This action should be performed only if the new track was explicitly requested by the user
        // (as opposed to being performed automatically by the player when the previous track completes)
        if context.cancelWaitingOrTranscoding {
            
            print("\tCanceling transcoding for:", context.requestedTrack?.conciseDisplayName)
        
            if context.currentState == .transcoding, let trackBeingTranscoded = context.currentTrack,
                trackBeingTranscoded != context.requestedTrack {
                
                // Don't cancel transcoding if same track will play next (but with different params e.g. delay or start position)
                transcoder.cancel(trackBeingTranscoded)
            }
            
            PlaybackGapContext.clear()
        }
        
        nextAction?.execute(context)
    }
}
