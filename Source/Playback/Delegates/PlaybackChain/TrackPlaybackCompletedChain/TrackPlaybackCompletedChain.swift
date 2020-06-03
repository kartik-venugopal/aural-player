import Foundation

class TrackPlaybackCompletedChain: PlaybackChain {
    
    private let startPlaybackChain: StartPlaybackChain
    private let stopPlaybackChain: StopPlaybackChain
    
    private let sequencer: SequencerProtocol
    
    init(_ startPlaybackChain: StartPlaybackChain, _ stopPlaybackChain: StopPlaybackChain, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.startPlaybackChain = startPlaybackChain
        self.stopPlaybackChain = stopPlaybackChain
        self.sequencer = sequencer
        
        super.init()
        
        _ = withAction(ResetPlaybackProfileAction(profiles))
        .withAction(DelayAfterTrackCompletionAction(playlist, sequencer, preferences))
    }
    
    override func execute(_ context: PlaybackRequestContext) {
        
        super.execute(context)
        
        context.requestedTrack = sequencer.subsequent()
        
        // Continue playback with the subsequent track (or stop if no subsequent track).
        context.requestedTrack != nil ? startPlaybackChain.execute(context) : stopPlaybackChain.execute(context)
    }
}
