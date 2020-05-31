import Foundation

class EndPlaybackSequenceAction: PlaybackChainAction {
    
    private let sequencer: SequencerProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ sequencer: SequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        // TODO: Revisit this ... audio graph can do both actions with just this 1 message: 1 - save old track settings, 2 - apply new track settings
        SyncMessenger.publishNotification(PreTrackChangeNotification(context.currentTrack, context.currentState, nil))
        
        sequencer.end()
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(context.currentTrack, context.currentState, nil))
        
        context.completed()
    }
}
