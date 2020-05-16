import Foundation

class EndPlaybackSequenceAction: PlaybackPreparationAction {
    
    private let sequencer: PlaybackSequencerProtocol
    
    var nextAction: PlaybackPreparationAction?
    
    init(_ sequencer: PlaybackSequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        sequencer.end()
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(context.currentTrack, context.currentState, nil))
    }
}
