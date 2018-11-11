import Foundation

/*
    A linear playback sequence that is unaware of the scope (entire playlist or specific group) from which the sequence was created. The size of the sequence will equal the number of tracks in the playback scope, and the indexes will represent absolute indexes within the sequence, that do not necessarily correspond to playlist indexes.
 
    Examples: 
 
         - If the scope was "All tracks" and there were 5 tracks in the playlist, the sequence might look like [0, 1, 2, 3, 4] or if shuffle is selected, maybe [2, 4, 3, 0, 1]
 
        - If the scope was "Artist Madonna" and there were 3 tracks in the Madonna artist group, the sequence might look like [0, 1, 2] or if shuffle is selected, maybe [2, 0, 1] ... regardless of how many total tracks there are in the entire playlist.
 */
class PlaybackSequence: PlaybackSequenceProtocol {
    
    private var repeatMode: RepeatMode = .off
    private var shuffleMode: ShuffleMode = .off
    
    // Total size of sequence (number of tracks)
    private var tracksCount: Int = 0
    
    // Cursor is the absolute sequence index of the currently playing track (nil if no track is playing)
    private var cursor: Int? = nil
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    private let shuffleSequence: ShuffleSequence = ShuffleSequence(0)
    
    init(_ tracksCount: Int, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
        reset(tracksCount: tracksCount)
    }
    
    func size() -> Int {
        return tracksCount
    }
    
    // Resets the sequence with a new tracksCount (i.e. size)
    func reset(tracksCount: Int) {
        self.tracksCount = tracksCount
        reset()
    }
    
    // Invalidates the cursor
    func resetCursor() {
        cursor = nil
    }
    
    // Resets the sequence with the first element in the sequence being the given index
    func reset(firstTrackIndex: Int?) {
        
        // If shuffle is on, recompute the shuffle sequence
        if (shuffleMode == .on) {
            if (firstTrackIndex != nil) {
                shuffleSequence.reset(capacity: tracksCount, firstTrackIndex: firstTrackIndex!)
            } else {
                shuffleSequence.reset(capacity: tracksCount)
            }
        }
        
        // The given index is the new cursor (i.e. playing track sequence index)
        cursor = firstTrackIndex
    }
    
    // Resets the sequence with a new size and the first track in the sequence being the given track index
    func reset(tracksCount: Int, firstTrackIndex: Int?) {
        
        self.tracksCount = tracksCount
        reset()
        
        // If shuffle is on, recompute the shuffle sequence
        if (shuffleMode == .on) {
            if (firstTrackIndex != nil) {
                shuffleSequence.reset(capacity: tracksCount, firstTrackIndex: firstTrackIndex!)
            } else {
                shuffleSequence.reset(capacity: tracksCount)
            }
        }
        
        cursor = firstTrackIndex
    }
    
    // Resets the sequence with the same size (intended to be used to re-shuffle the tracks)
    private func reset() {
        
        // If shuffle is on, recompute the shuffle sequence
        if (shuffleMode == .on) {
            
            // TODO: Can this logic be moved to ShuffleSequence, and its sequence variable be made private ???
            
            let lastSequenceLastElement = shuffleSequence.sequence.last
            let lastSequenceCount = shuffleSequence.sequence.count
            
            shuffleSequence.reset(capacity: tracksCount)
            
            // Ensure that the first element of the new sequence is different from the last element of the previous sequence, so that no track is played twice in a row
            if (lastSequenceCount > 1 && lastSequenceLastElement != nil && tracksCount > 1) {
                if (shuffleSequence.peekNext() == lastSequenceLastElement) {
                    swapFirstTwoShuffleSequenceElements()
                }
            }
            
            // Make sure that the first track does not match the currently playing track
            if (tracksCount > 1 && shuffleSequence.peekNext() == cursor) {
                swapFirstTwoShuffleSequenceElements()
            }
        }
    }
    
    private func swapFirstTwoShuffleSequenceElements() {
        
        let temp = shuffleSequence.sequence[0]
        shuffleSequence.sequence[0] = shuffleSequence.sequence[1]
        shuffleSequence.sequence[1] = temp
    }
    
    func clear() {
        shuffleSequence.clear()
        tracksCount = 0
        cursor = nil
    }
    
    func select(_ index: Int) {
        
        // When a specific index is selected, the sequence is reset
        cursor = index
        reset(firstTrackIndex: index)
    }
    
    func getCursor() -> Int? {
        return cursor
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        switch repeatMode {
            
        case .off:
            
            repeatMode = .one
            
            // If repeating one track, cannot also shuffle
            if (shuffleMode == .on) {
                shuffleMode = .off
                shuffleSequence.clear()
            }
            
        case .one: repeatMode = .all
        case .all: repeatMode = .off
            
        }
        
        return (repeatMode, shuffleMode)
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        
        // If repeating one track, cannot also shuffle
        if (repeatMode == .one && shuffleMode == .on) {
            shuffleMode = .off
            shuffleSequence.clear()
        }
        
        return (repeatMode, shuffleMode)
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        switch shuffleMode {
            
        case .off: shuffleMode = .on
        
        // Can't shuffle and repeat one track
        if (repeatMode == .one) {
            repeatMode = .off
        }
            
            reset(firstTrackIndex: cursor)
            
        case .on: shuffleMode = .off
            shuffleSequence.clear()
            
        }
        
        return (repeatMode, shuffleMode)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        self.shuffleMode = shuffleMode
        
        switch shuffleMode {
            
        case .on:
        
        // Can't shuffle and repeat one track
        if (repeatMode == .one) {
            repeatMode = .off
        }
        
        reset(firstTrackIndex: cursor)
            
        case .off: shuffleSequence.clear()
            
        }
        
        return (repeatMode, shuffleMode)
    }
    
    func subsequent() -> Int? {

        if (tracksCount == 0) {
            cursor = nil
            return cursor
        }
        
        if (repeatMode == .off && shuffleMode == .off) {
            
            // Next track sequentially
            if (cursor != nil && (cursor! < tracksCount - 1)) {
                
                // Has more tracks, pick the next one
                cursor = cursor! + 1
                
            } else if (cursor == nil) {
                
                // Nothing playing, return the first one
                cursor = 0
                
            } else {
                
                // Last track reached, nothing further to play
                cursor = nil
            }
            
            return cursor
        }
        
        if (repeatMode == .off && shuffleMode == .on) {
            
            // If the sequence is complete (all tracks played), reset it
            if (shuffleSequence.ended()) {
                reset()
                cursor = nil
                return cursor
            }
            
            // Pick the next track in the sequence
            let next = shuffleSequence.next()!
            cursor = next
            
            return cursor
        }
        
        if (repeatMode == .one) {
            
            // Easy, just play the same thing, regardless of shuffleMode
            
            if (cursor == nil) {
                cursor = 0
            }
            
            return cursor
        }
        
        if (repeatMode == RepeatMode.all && shuffleMode == .off) {
            
            // Similar to repeat OFF, just don't stop at the end
            
            // Next track sequentially
            if (cursor != nil && (cursor! < tracksCount - 1)) {
                
                // Has more tracks, pick the next one
                cursor = cursor! + 1
                
            } else {
                
                // Last track reached or nothing playing, play the first track
                cursor = 0
            }
            
            return cursor
        }
        
        // Repeat all, shuffle on
        if (repeatMode == .all && shuffleMode == .on) {
            
            // If shuffle sequence has ended, just create a new one, and keep going
            if (shuffleSequence.ended()) {
                reset()
            }
            
            let next = shuffleSequence.next()!
            cursor = next
            
            return cursor
        }
        
        // Impossible
        return nil
    }
    
    func next() -> Int? {
        
        // NOTE - If the result is nil, don't modify the cursor, because next() should not end the currently playing track if there is one
        
        if (tracksCount == 0 || tracksCount == 1 || cursor == nil) {
            return nil
        }
        
        if (repeatMode == .off && shuffleMode == .off) {
            
            // Next track sequentially
            if (cursor! < tracksCount - 1) {
                
                // Has more tracks, pick the next one
                cursor = cursor! + 1
                
            } else {
                
                // Last track reached, nothing further to play
                return nil
            }
            
            return cursor
        }
        
        if (repeatMode == .off && shuffleMode == .on) {
            
            // If the sequence is complete (all tracks played), nothing more to play
            if (shuffleSequence.ended()) {
                return nil
            }
            
            // Pick the next track in the sequence
            let next = shuffleSequence.next()!
            cursor = next
            
            return cursor
        }
        
        if (repeatMode == .one) {
            
            // Next track sequentially
            if (cursor! < tracksCount - 1) {
                
                // Has more tracks, pick the next one
                cursor = cursor! + 1
                
            } else {
                
                // Last track reached, no next track
                return nil
            }
            
            return cursor
        }
        
        if (repeatMode == RepeatMode.all && shuffleMode == .off) {
            
            // Similar to repeat OFF, just don't stop at the end
            
            // Next track sequentially
            if (cursor! < tracksCount - 1) {
                
                // Has more tracks, pick the next one
                cursor = cursor! + 1
                
            } else {
                
                // Last track reached or nothing playing, play the first track
                cursor = 0
            }
            
            return cursor
        }
        
        // Repeat all, shuffle on
        if (repeatMode == RepeatMode.all && shuffleMode == .on) {
            
            // If shuffle sequence has ended, just create a new one, and keep going
            if (shuffleSequence.ended()) {
                reset()
            }
            
            let next = shuffleSequence.next()!
            cursor = next
            
            return cursor
        }
        
        // Impossible
        return nil
    }
    
    func previous() -> Int? {
        
        // NOTE - If the result is nil, don't modify the cursor, because previous() should not end the currently playing track if there is one
        
        if (tracksCount == 0 || tracksCount == 1 || cursor == nil) {
            return nil
        }
        
        if (repeatMode == .off && shuffleMode == .off) {
            
            // Previous track sequentially
            if (cursor! > 0) {
                
                // Has more tracks, pick the previous one
                cursor = cursor! - 1
                
            } else {
                
                // First track reached, nothing further to play
                return nil
            }
            
            return cursor
        }
        
        if (repeatMode == .off && shuffleMode == .on) {
            
            // If the sequence has just started, there is no previous track
            if (shuffleSequence.started()) {
                return nil
            }
            
            // Pick the previous track in the sequence
            let previous = shuffleSequence.previous()!
            cursor = previous
            
            return cursor
        }
        
        if (repeatMode == .one) {
            
            // Previous track sequentially
            if (cursor! > 0) {
                
                // Has more tracks, pick the previous one
                cursor = cursor! - 1
                
            } else {
                
                // First track reached, no previous track
                return nil
            }
            
            return cursor
        }
        
        if (repeatMode == RepeatMode.all && shuffleMode == .off) {
            
            // Similar to repeat OFF, just don't stop at the beginning
            
            // Previous track sequentially
            if (cursor! > 0) {
                
                // Has more tracks, pick the previous one
                cursor = cursor! - 1
                
            } else {
                
                // First track reached, play the last track
                cursor = tracksCount - 1
            }
            
            return cursor
        }
        
        // Repeat all, shuffle on
        if (repeatMode == RepeatMode.all && shuffleMode == .on) {
            
            // If the sequence has just started, there is no previous track
            if (shuffleSequence.started()) {
                return nil
            }
            
            // Pick the previous track in the sequence
            let previous = shuffleSequence.previous()!
            cursor = previous
            
            return cursor
        }
        
        // Impossible
        return nil
    }
    
    func peekSubsequent() -> Int? {
        
        if (tracksCount == 0) {
            return nil
        }
        
        if (repeatMode == .off && shuffleMode == .off) {
            
            // Next track sequentially
            if (cursor != nil && (cursor! < tracksCount - 1)) {
                
                // Has more tracks, pick the next one
                return cursor! + 1
                
            } else if (cursor == nil) {
                
                // Nothing playing, return the first one
                return 0
                
            } else {
                
                // Last track reached, nothing further to play
                return nil
            }
        }
        
        if (repeatMode == .off && shuffleMode == .on) {
            
            // If the sequence is complete (all tracks played), no track
            if (shuffleSequence.ended()) {
                return nil
            }
            
            // Pick the next track in the sequence
            return shuffleSequence.peekNext()
        }
        
        if (repeatMode == .one) {
            
            // Easy, just play the same thing, regardless of shuffleMode
            
            if (cursor == nil) {
                return 0
            }
            
            return cursor
        }
        
        if (repeatMode == RepeatMode.all && shuffleMode == .off) {
            
            // Similar to repeat OFF, just don't stop at the end
            
            // Next track sequentially
            if (cursor != nil && (cursor! < tracksCount - 1)) {
                
                // Has more tracks, pick the next one
                return cursor! + 1
                
            } else {
                
                // Last track reached or nothing playing, play the first track
                return 0
            }
        }
        
        // Repeat all, shuffle on
        if (repeatMode == .all && shuffleMode == .on) {
            
            // If shuffle sequence has ended, just create a new one, and keep going
            if (shuffleSequence.ended()) {
                // Cannot predict next track because sequence will be reset
                return nil
            }
            
            return shuffleSequence.peekNext()
        }
        
        // Impossible
        return nil
    }
    
    func peekNext() -> Int? {
        
        // NOTE - If the result is nil, don't modify the cursor, because next() should not end the currently playing track if there is one
        
        if (tracksCount == 0 || cursor == nil) {
            return nil
        }
        
        if (repeatMode == .off && shuffleMode == .off) {
            
            // Next track sequentially
            if (cursor! < tracksCount - 1) {
                
                // Has more tracks, pick the next one
                return cursor! + 1
                
            } else {
                
                // Last track reached, nothing further to play
                return nil
            }
        }
        
        if (repeatMode == .off && shuffleMode == .on) {
            
            // If the sequence is complete (all tracks played), nothing more to play
            if (shuffleSequence.ended()) {
                return nil
            }
            
            // Pick the next track in the sequence
            return shuffleSequence.peekNext()
        }
        
        if (repeatMode == .one) {
            
            // Next track sequentially
            if (cursor! < tracksCount - 1) {
                
                // Has more tracks, pick the next one
                return cursor! + 1
                
            } else {
                
                // Last track reached, no next track
                return nil
            }
        }
        
        if (repeatMode == RepeatMode.all && shuffleMode == .off) {
            
            // Similar to repeat OFF, just don't stop at the end
            
            // Next track sequentially
            if (cursor! < tracksCount - 1) {
                
                // Has more tracks, pick the next one
                return cursor! + 1
                
            } else {
                
                // Last track reached or nothing playing, play the first track
                return 0
            }
        }
        
        // Repeat all, shuffle on
        if (repeatMode == RepeatMode.all && shuffleMode == .on) {
            
            // If shuffle sequence has ended, just create a new one, and keep going
            if (shuffleSequence.ended()) {
                // Cannot predict next track because sequence will be reset
                return nil
            }
            
            return shuffleSequence.peekNext()
        }
        
        // Impossible
        return nil
    }
    
    func peekPrevious() -> Int? {
        
        // NOTE - If the result is nil, don't modify the cursor, because previous() should not end the currently playing track if there is one
        
        if (tracksCount == 0 || cursor == nil) {
            return nil
        }
        
        if (repeatMode == .off && shuffleMode == .off) {
            
            // Previous track sequentially
            if (cursor! > 0) {
                
                // Has more tracks, pick the previous one
                return cursor! - 1
                
            } else {
                
                // First track reached, nothing further to play
                return nil
            }
        }
        
        if (repeatMode == .off && shuffleMode == .on) {
            
            // If the sequence has just started, there is no previous track
            if (shuffleSequence.started()) {
                return nil
            }
            
            // Pick the previous track in the sequence
            return shuffleSequence.peekPrevious()
        }
        
        if (repeatMode == .one) {
            
            // Previous track sequentially
            if (cursor! > 0) {
                
                // Has more tracks, pick the previous one
                return cursor! - 1
                
            } else {
                
                // First track reached, no previous track
                return nil
            }
        }
        
        if (repeatMode == RepeatMode.all && shuffleMode == .off) {
            
            // Similar to repeat OFF, just don't stop at the beginning
            
            // Previous track sequentially
            if (cursor! > 0) {
                
                // Has more tracks, pick the previous one
                return cursor! - 1
                
            } else {
                
                // First track reached, play the last track
                return tracksCount - 1
            }
        }
        
        // Repeat all, shuffle on
        if (repeatMode == RepeatMode.all && shuffleMode == .on) {
            
            // If the sequence has just started, there is no previous track
            if (shuffleSequence.started()) {
                return nil
            }
            
            // Pick the previous track in the sequence
            return shuffleSequence.peekPrevious()
        }
        
        // Impossible
        return nil
    }
    
    func getPersistentState() -> PlaybackSequenceState {
        
        let state = PlaybackSequenceState()
        state.repeatMode = repeatMode
        state.shuffleMode = shuffleMode
        
        return state
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return (repeatMode, shuffleMode)
    }
}
