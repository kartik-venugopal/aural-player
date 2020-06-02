import Foundation

class SetPlaybackDelayAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let playlist: PlaylistCRUDProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ playlist: PlaylistCRUDProtocol) {
        
        self.player = player
        self.playlist = playlist
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        let params = context.requestParams
        
        if params.allowDelay {

            // An explicit delay is defined in the request parameters. It takes precedence over any gaps.
            if let delay = params.delay {
                
                context.addGap(PlaybackGap(delay, .beforeTrack, .oneTime))
                
            }   // No explicit delay in the request parameters is defined, check for a gap defined before the track (in the playlist).
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
