import Foundation

/*
   Computes the delay before playback of a requested track.
*/
class SetPlaybackDelayAction: PlaybackChainAction {
    
    private let playlist: PlaylistCRUDProtocol
    
    init(_ playlist: PlaylistCRUDProtocol) {
        self.playlist = playlist
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Terminate if no requested track is specified
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        let params = context.requestParams
        
        // If the request does not allow a delay, skip this action.
        if params.allowDelay {

            // An explicit delay is defined in the request parameters. It takes precedence over any playlist gaps.
            if let delay = params.delay {
                
                // Remove any previously defined gaps (eg. when track completion occurred)
                context.removeAllGaps()
                context.addGap(PlaybackGap(delay, .beforeTrack, .oneTime))
            }
            // No explicit delay in the request parameters is defined, check for a gap defined before the track (in the playlist).
            else if let gapBeforeNewTrack = playlist.getGapBeforeTrack(newTrack) {
                
                // Add the gap's duration to the total delay before playback.
                context.addGap(gapBeforeNewTrack)

                // If the gap is a one-time gap, remove it from the playlist
                if gapBeforeNewTrack.type == .oneTime {
                    playlist.removeGapForTrack(newTrack, gapBeforeNewTrack.position)
                }
            }
        }
        
        chain.proceed(context)
    }
}
