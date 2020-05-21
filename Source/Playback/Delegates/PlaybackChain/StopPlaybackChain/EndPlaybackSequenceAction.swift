import Foundation

class EndPlaybackSequenceAction: PlaybackChainAction {
    
    private let sequencer: PlaybackSequencerProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ sequencer: PlaybackSequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        SyncMessenger.publishNotification(PreTrackChangeNotification(context.currentTrack, context.currentState, nil))
        
        sequencer.end()
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(context.currentTrack, context.currentState, nil))
    }
}
