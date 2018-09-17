import Foundation

/*
    Concrete implementation of PlaybackSequencerInfoDelegateProtocol
 */
class PlaybackSequencerInfoDelegate: PlaybackSequencerInfoDelegateProtocol {
    
    private let sequencer: PlaybackSequencerProtocol
    
    init(_ sequencer: PlaybackSequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func peekSubsequent() -> IndexedTrack? {
        return sequencer.peekSubsequent()
    }
    
    func peekPrevious() -> IndexedTrack? {
        return sequencer.peekPrevious()
    }
    
    func peekNext() -> IndexedTrack? {
        return sequencer.peekNext()
    }
}
