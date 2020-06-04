import Foundation

class DelayAfterTrackCompletionAction: PlaybackChainAction {
    
    private let playlist: PlaylistCRUDProtocol
    private let sequencer: SequencerProtocol
    private let preferences: PlaybackPreferences
    
    init(_ playlist: PlaylistCRUDProtocol, _ sequencer: SequencerProtocol, _ preferences: PlaybackPreferences) {
        
        self.playlist = playlist
        self.sequencer = sequencer
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Adding a delay is only relevant when a track has completed and there is a subsequent track to play.
        if let completedTrack = context.currentTrack, sequencer.peekSubsequent() != nil {
            
            // First, check for an explicit gap defined in the playlist (takes precedence over global preference).
            if let gapAfterCompletedTrack = playlist.getGapAfterTrack(completedTrack) {
                
                context.addGap(gapAfterCompletedTrack)
                
                // If the gap is a one-time gap, remove it from the playlist
                if gapAfterCompletedTrack.type == .oneTime {
                    playlist.removeGapForTrack(completedTrack, gapAfterCompletedTrack.position)
                }
                
            } // No playlist gap defined, check for an implicit gap defined by playback preferences.
            else if preferences.gapBetweenTracks {
                
                context.addGap(PlaybackGap(Double(preferences.gapBetweenTracksDuration), .afterTrack, .implicit))
            }
        }
        
        chain.proceed(context)
    }
}
