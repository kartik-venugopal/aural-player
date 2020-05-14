import Foundation

/*
    Concrete implementation of PlaybackSequencerInfoDelegateProtocol
 */
class PlaybackSequencerDelegate: PlaybackSequencerDelegateProtocol {
    
    private let sequencer: PlaybackSequencerProtocol
    
    init(_ sequencer: PlaybackSequencerProtocol) {
        self.sequencer = sequencer
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {return sequencer.repeatAndShuffleModes}
    
    var playingTrack: IndexedTrack? {
        return sequencer.playingTrack
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
