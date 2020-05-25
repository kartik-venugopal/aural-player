import Foundation

class DelayAfterTrackCompletionAction: PlaybackChainAction {
    
    private let playlist: PlaylistAccessorProtocol
    
    private let sequencer: SequencerProtocol
    
    private let preferences: PlaybackPreferences
    
    var nextAction: PlaybackChainAction?
    
    init(_ playlist: PlaylistAccessorProtocol, _ sequencer: SequencerProtocol, _ preferences: PlaybackPreferences) {
        
        self.playlist = playlist
        self.sequencer = sequencer
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let completedTrack = context.currentTrack, sequencer.peekSubsequent() != nil else {return}
        
        // First, check for an explicit gap defined by the user (takes precedence over implicit gap defined by playback preferences)
        if let gapAfterCompletedTrack = playlist.getGapAfterTrack(completedTrack) {
            
            PlaybackGapContext.addGap(gapAfterCompletedTrack, completedTrack)
            
        } else if preferences.gapBetweenTracks {
            
            // Check for an implicit gap defined by playback preferences
            
            let gapDuration = Double(preferences.gapBetweenTracksDuration)
            let gap = PlaybackGap(gapDuration, .afterTrack, .implicit)
            
            PlaybackGapContext.addGap(gap, completedTrack)
        }
        
        nextAction?.execute(context)
    }
}
