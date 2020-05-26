import Foundation

class MockSequencer: SequencerProtocol {
    
    var beginTrack: Track?
    var subsequentTrack: Track?
    var previousTrack: Track?
    var nextTrack: Track?
    
    var playingTrack: Track? = nil
    
    var selectionTracksByIndex: [Int: Track] = [:]
    var selectionTracksByGroup: [Group: Track] = [:]
    var selectedTrack: Track?
    
    var beginCallCount: Int = 0
    var endCallCount: Int = 0
    
    var subsequentCallCount: Int = 0
    var previousCallCount: Int = 0
    var nextCallCount: Int = 0
    
    var peekSubsequentCallCount: Int = 0
    var peekPreviousCallCount: Int = 0
    var peekNextCallCount: Int = 0
    
    var selectIndexCallCount: Int = 0
    var selectTrackCallCount: Int = 0
    var selectGroupCallCount: Int = 0
    
    func reset() {
        
        beginTrack = nil
        subsequentTrack = nil
        previousTrack = nil
        nextTrack = nil

        selectionTracksByIndex.removeAll()
        selectionTracksByGroup.removeAll()
    }
    
    func begin() -> Track? {
        
        beginCallCount.increment()
        
        playingTrack = beginTrack
        return playingTrack
    }
    
    func end() {
        
        endCallCount.increment()
        
        playingTrack = nil
    }
    
    func subsequent() -> Track? {
        
        subsequentCallCount.increment()
        
        playingTrack = subsequentTrack
        return playingTrack
    }
    
    func previous() -> Track? {
        
        previousCallCount.increment()
        
        if previousTrack != nil {
            playingTrack = previousTrack
            return previousTrack
        }
        
        return nil
    }
    
    func next() -> Track? {
        
        nextCallCount.increment()
        
        if nextTrack != nil {
            playingTrack = nextTrack
            return nextTrack
        }
        
        return nil
    }
    
    func peekSubsequent() -> Track? {
        
        peekSubsequentCallCount.increment()
        return subsequentTrack
    }
    
    func peekPrevious() -> Track? {
        
        peekPreviousCallCount.increment()
        return previousTrack
    }
    
    func peekNext() -> Track? {
        
        peekNextCallCount.increment()
        return nextTrack
    }
    
    func select(_ index: Int) -> Track? {
        
        selectIndexCallCount.increment()
        
        playingTrack = selectionTracksByIndex[index]
        return playingTrack
    }
    
    func select(_ track: Track) -> Track? {
        
        selectTrackCallCount.increment()
        
        playingTrack = track
        return playingTrack
    }
    
    func select(_ group: Group) -> Track? {
        
        selectGroupCallCount.increment()
        
        playingTrack = selectionTracksByGroup[group]
        return playingTrack
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return repeatAndShuffleModes
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return repeatAndShuffleModes
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return repeatAndShuffleModes
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return repeatAndShuffleModes
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return (.off, .off)
    }
    
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        return (SequenceScope(.allTracks), 1, 10)
    }
}
