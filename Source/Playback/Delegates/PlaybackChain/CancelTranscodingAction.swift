import Foundation

/*
    Cancels transcoding for a current track, if required.
*/
class CancelTranscodingAction: PlaybackChainAction {
    
    private let transcoder: TranscoderProtocol
    
    init(_ transcoder: TranscoderProtocol) {
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // NOTE - Don't cancel transcoding if the same track will play next
        // (but with different params e.g. delay or start position)
        
        if context.currentState == .transcoding, let trackBeingTranscoded = context.currentTrack,
            trackBeingTranscoded != context.requestedTrack {

            transcoder.cancelTranscoding(trackBeingTranscoded)
        }
        
        chain.proceed(context)
    }
}
