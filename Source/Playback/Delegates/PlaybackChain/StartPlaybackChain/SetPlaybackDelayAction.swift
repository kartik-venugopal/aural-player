import Foundation

class SetPlaybackDelayAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let playlist: PlaylistCRUDProtocol
    private let preferences: PlaybackPreferences
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ playlist: PlaylistCRUDProtocol, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.playlist = playlist
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let newTrack = context.requestedTrack else {return}
        
        let params = context.requestParams
        
        if params.allowDelay {

            // An explicit delay is defined in the request parameters. It takes precedence over any gaps.
            if let delay = params.delay {
                
                context.setDelay(delay)
                
            }   // No explicit delay in the request parameters is defined, check for a gap defined before the track (in the playlist).
            else if let gapBeforeNewTrack = playlist.getGapBeforeTrack(newTrack) {
                
                // Add the gap's duration to the total delay before playback.
                context.addDelay(gapBeforeNewTrack.duration)

                // If the gap is a one-time gap, remove it from the playlist
                if gapBeforeNewTrack.type == .oneTime {
                    playlist.removeGapForTrack(newTrack, gapBeforeNewTrack.position)
                }
            }
            
            // No explicit delay or playlist gaps defined, check for an implicit gap defined by playback preferences.
            if context.delay == nil && preferences.gapBetweenTracks {
                context.setDelay(Double(preferences.gapBetweenTracksDuration))
            }
        }
            
        nextAction?.execute(context)
    }
}
