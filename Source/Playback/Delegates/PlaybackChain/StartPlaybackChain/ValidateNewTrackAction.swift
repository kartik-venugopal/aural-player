import Foundation

/*
   Validates a requested track (i.e. audio) prior to playback.
*/
class ValidateNewTrackAction: PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Terminate if no requested track is specified
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, NoRequestedTrackError.instance)
            return
        }
        
        // Validate the track
//        newTrack.validateAudio()
//
//        if newTrack.lazyLoadingInfo.preparationFailed, let preparationError = newTrack.lazyLoadingInfo.preparationError {
//
//            // Validation failed, terminate the chain.
//            chain.terminate(context, preparationError)
//
//        } else {
//
            // Track is valid, OK to proceed
            chain.proceed(context)
//        }
    }
}
