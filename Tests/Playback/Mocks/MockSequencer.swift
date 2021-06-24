//
//  MockSequencer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class MockSequencer: SequencerProtocol {
    
    var beginTrack: Track?
    var subsequentTrack: Track?
    var previousTrack: Track?
    var nextTrack: Track?
    
    var currentTrack: Track? = nil
    
    var selectionTracksByIndex: [Int: Track] = [:]
    var selectionTracksByGroup: [Group: Track] = [:]
    
    var selectedIndex: Int?
    var selectedTrack: Track?
    var selectedGroup: Group?
    
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
        
        selectedIndex = nil
        selectedTrack = nil
        selectedGroup = nil
        
        beginCallCount = 0
        endCallCount = 0
        
        subsequentCallCount = 0
        previousCallCount = 0
        nextCallCount = 0
        
        peekSubsequentCallCount = 0
        peekPreviousCallCount = 0
        peekNextCallCount = 0
        
        selectIndexCallCount = 0
        selectTrackCallCount = 0
        selectGroupCallCount = 0
    }
    
    func begin() -> Track? {
        
        beginCallCount.increment()
        
        currentTrack = beginTrack
        return currentTrack
    }
    
    func end() {
        
        endCallCount.increment()
        currentTrack = nil
    }
    
    func subsequent() -> Track? {
        
        subsequentCallCount.increment()
        
        currentTrack = subsequentTrack
        return currentTrack
    }
    
    func previous() -> Track? {
        
        previousCallCount.increment()
        
        if previousTrack != nil {
            currentTrack = previousTrack
            return previousTrack
        }
        
        return nil
    }
    
    func next() -> Track? {
        
        nextCallCount.increment()
        
        if nextTrack != nil {
            currentTrack = nextTrack
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
        selectedIndex = index
        
        currentTrack = selectionTracksByIndex[index]
        return currentTrack
    }
    
    func select(_ track: Track) -> Track? {
        
        selectTrackCallCount.increment()
        selectedTrack = track
        
        currentTrack = track
        return currentTrack
    }
    
    func select(_ group: Group) -> Track? {
        
        selectGroupCallCount.increment()
        selectedGroup = group
        
        currentTrack = selectionTracksByGroup[group]
        return currentTrack
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
