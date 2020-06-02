import Foundation

class ValidateNewTrackAction: PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        newTrack.validateAudio()
        
        // Validate track before attempting to play it
        if newTrack.lazyLoadingInfo.preparationFailed, let preparationError = newTrack.lazyLoadingInfo.preparationError {
        
            chain.terminate(context, preparationError)
            
        } else {
            
            // Track is valid, OK to proceed
            chain.proceed(context)
        }
    }
}
