import Foundation

class SetPlaybackDelayAction: PlaybackPreparationAction {
    
    private let player: PlayerProtocol
    private let playlist: PlaylistCRUDProtocol
    
    init(_ player: PlayerProtocol, _ playlist: PlaylistCRUDProtocol) {
        self.player = player
        self.playlist = playlist
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        let params = context.requestParams
        
        guard params.allowDelay, let newTrack = context.requestedTrack else {return true}
            
        if let delay = params.delay {

            // An explicit delay is defined. It takes precedence over gaps.
            PlaybackGapContext.clear()
            PlaybackGapContext.addGap(PlaybackGap(delay, .beforeTrack), newTrack)
            
        } else {
            
            // No explicit delay is defined, check for a gap defined before the track (in the playlist).
            if let gapBefore = playlist.getGapBeforeTrack(newTrack.track) {

                // The explicitly defined gap before the track takes precedence over the implicit gap
                // defined by the playback preferences, so remove the implicit gap
                PlaybackGapContext.addGap(gapBefore, newTrack)
                PlaybackGapContext.removeImplicitGap()
            }
            
            if PlaybackGapContext.hasGaps() {
                
                // Check if any defined gaps were one-time gaps. If so, delete them
                for (gap, indexedTrack) in PlaybackGapContext.oneTimeGaps {
                    playlist.removeGapForTrack(indexedTrack.track, gap.position)
                }
                
                // Set the delay request parameter to the lengtth of the gap.
                params.delay = PlaybackGapContext.gapLength
            }
        }
        
        return true
    }
}
