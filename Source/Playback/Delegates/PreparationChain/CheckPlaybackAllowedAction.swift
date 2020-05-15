import Foundation

class CheckPlaybackAllowedAction: PlaybackPreparationAction {
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        /*
            Playback is allowed if either:
         
            1 - the request parameters indicate it is ok to interrupt current track playback.
         
            OR
         
            2 - no track is currently playing
         */
        return context.requestParams.interruptPlayback || context.currentTrack == nil
    }
}
