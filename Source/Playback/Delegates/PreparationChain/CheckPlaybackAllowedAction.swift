import Foundation

class CheckPlaybackAllowedAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
    func execute(_ context: PlaybackRequestContext) {
        
        /*
            Playback is allowed if either:
         
            1 - the request parameters indicate it is ok to interrupt current track playback.
         
            OR
         
            2 - no track is currently playing
         */
        if context.requestParams.interruptPlayback || context.currentTrack == nil {
            nextAction?.execute(context)
        }
    }
}
