import Foundation

class DelayAfterTrackCompletionAction: PlaybackChainAction {
    
    private let playlist: PlaylistCRUDProtocol
    
    private let sequencer: SequencerProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ playlist: PlaylistCRUDProtocol, _ sequencer: SequencerProtocol) {
        
        self.playlist = playlist
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let completedTrack = context.currentTrack, sequencer.peekSubsequent() != nil else {return}
        
        // First, check for an explicit gap defined by the user (takes precedence over implicit gap defined by playback preferences)
        if let gapAfterCompletedTrack = playlist.getGapAfterTrack(completedTrack) {
            
            context.addDelay(gapAfterCompletedTrack.duration)
            
            // If the gap is a one-time gap, remove it from the playlist
            if gapAfterCompletedTrack.type == .oneTime {
                playlist.removeGapForTrack(completedTrack, gapAfterCompletedTrack.position)
            }
        }
        
        nextAction?.execute(context)
    }
}
