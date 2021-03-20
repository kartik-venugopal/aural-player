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
        
        Messenger.publish(PreTrackChangeNotification(oldTrack: context.currentTrack, oldState: context.currentState, newTrack: nil))
        
        sequencer.end()
        
        Messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: nil, endState: .noTrack))
        
        chain.proceed(context)
    }
}
