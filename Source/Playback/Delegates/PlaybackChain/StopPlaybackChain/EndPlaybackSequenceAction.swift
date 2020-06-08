import Foundation

/*
   Action that ends the sequencer's playback sequence and notifies observers.
*/
class EndPlaybackSequenceAction: PlaybackChainAction {
    
    private let sequencer: SequencerProtocol
    
    init(_ sequencer: SequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        SyncMessenger.publishNotification(PreTrackChangeNotification(context.currentTrack, context.currentState, nil))
        
        sequencer.end()
        
        AsyncMessenger.publishMessage(TrackTransitionAsyncMessage(context.currentTrack, context.currentState, nil, .noTrack))
        
        // Mark the playback chain as having completed execution.
        chain.complete(context)
    }
}
