import Foundation

class CancelTranscodingAction: PlaybackChainAction {
    
    private let transcoder: TranscoderProtocol
    
    init(_ transcoder: TranscoderProtocol) {
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // This action should be performed only if the new track was explicitly requested by the user
        // (as opposed to being requested automatically by the player when the previous track completes)
        
        // NOTE - Don't cancel transcoding if the same track will play next
        // (but with different params e.g. delay or start position)
        
        if context.currentState == .transcoding, let trackBeingTranscoded = context.currentTrack,
            trackBeingTranscoded != context.requestedTrack {

            transcoder.cancelTranscoding(trackBeingTranscoded)
        }
        
        chain.proceed(context)
    }
}
