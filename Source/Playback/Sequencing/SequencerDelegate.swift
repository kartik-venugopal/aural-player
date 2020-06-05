import Foundation

/*
    Concrete implementation of PlaybackSequencerInfoDelegateProtocol
 */
class SequencerDelegate: SequencerDelegateProtocol {
    
    private let sequencer: SequencerProtocol
    
    init(_ sequencer: SequencerProtocol) {
        self.sequencer = sequencer
    }
    
    var currentTrack: Track? {
        return sequencer.currentTrack
    }
    
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        return sequencer.sequenceInfo
    }
    
    func peekSubsequent() -> Track? {
        return sequencer.peekSubsequent()
    }
    
    func peekPrevious() -> Track? {
        return sequencer.peekPrevious()
    }
    
    func peekNext() -> Track? {
        return sequencer.peekNext()
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.repeatAndShuffleModes
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.toggleRepeatMode()
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.setRepeatMode(repeatMode)
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.toggleShuffleMode()
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.setShuffleMode(shuffleMode)
    }
}
