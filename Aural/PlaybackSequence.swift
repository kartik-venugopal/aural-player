/*
    Computes the playback sequence for the playlist
 */

import Foundation

class PlaybackSequence: PlaylistChangeListener, PlaybackSequenceProtocol {
    
    private var repeatMode: RepeatMode = .off
    private var shuffleMode: ShuffleMode = .off
    
    private var tracksCount: Int = 0
    
    // Cursor is the playlist index of the currently playing track (nil if no track is playing)
    private var cursor: Int? = nil
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    private let shuffleSequence: ShuffleSequence = ShuffleSequence(0)
    
    init(_ tracksCount: Int, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
        reset(tracksCount: tracksCount)
    }
    
    private func reset(tracksCount: Int) {
        self.tracksCount = tracksCount
        reset()
    }
    
    private func reset(firstTrackIndex: Int?) {
        
        if (shuffleMode == .on) {
            if (firstTrackIndex != nil) {
                shuffleSequence.reset(capacity: tracksCount, firstTrackIndex: firstTrackIndex!)
            } else {
                shuffleSequence.reset(capacity: tracksCount)
            }
        }
    }
    
    // Recomputes the shuffle sequence, if necessary
    private func reset() {
        
        if (shuffleMode == .on) {
            
            // TODO: Can this logic be moved to ShuffleSequence, and its sequence variable be made private ???
            
            let lastSequenceLastElement = shuffleSequence.sequence.last
            let lastSequenceCount = shuffleSequence.sequence.count
            
            shuffleSequence.reset(capacity: tracksCount)
            
            // Ensure that the first element of the new sequence is different from the last element of the previous sequence, so that no track is played twice in a row
            if (lastSequenceCount > 1 && lastSequenceLastElement != nil && tracksCount > 1) {
                if (shuffleSequence.peekNext() == lastSequenceLastElement) {
                    swapFirstTwoSequenceElements()
                }
            }
            
            // Make sure that the first track does not match the currently playing track
            if (tracksCount > 1 && shuffleSequence.peekNext() == cursor) {
                swapFirstTwoSequenceElements()
            }
        }
    }
    
    private func swapFirstTwoSequenceElements() {
        swap(&shuffleSequence.sequence[0], &shuffleSequence.sequence[1])
    }
    
    func trackAdded() {
        if (shuffleMode == .on) {
            shuffleSequence.insertElement(elm: tracksCount)
        }
        tracksCount += 1
    }
    
    func clear() {
        shuffleSequence.clear()
        tracksCount = 0
        cursor = nil
    }
    
    func playlistCleared() {
        clear()
    }
    
    func playlistReordered(_ newCursor: Int?) {
        cursor = newCursor
        reset(firstTrackIndex: cursor)
    }
    
    func select(_ index: Int) {
        cursor = index
        reset(firstTrackIndex: index)
    }
    
    func getCursor() -> Int? {
        return cursor
    }
    
    func trackRemoved(_ removedTrackIndex: Int) {
        
        // If playingTrackIndex >= removedTrackIndex, it will change
        
        // Playing track removed
        if (cursor == removedTrackIndex) {
            cursor = nil
        } else if (cursor != nil && cursor! > removedTrackIndex) {
            // Move the cursor up one index, if it is below the removed track
            cursor! -= 1
        }
        
        tracksCount -= 1
        reset(firstTrackIndex: cursor)
    }
    
    func trackReordered(_ oldIndex: Int, _ newIndex: Int) {
        
        // If playingTrackIndex == oldIndex or newIndex, it will change
        
        // Playing track was moved
        if (cursor == oldIndex) {
            cursor = newIndex
        } else if (cursor == newIndex) { // Track adjacent to playing track was moved
            cursor = oldIndex
        }
        
        reset(firstTrackIndex: cursor)
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        switch repeatMode {
            
        case .off: repeatMode = .one
        
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
    
    // Determines the next track to play when playback of a (previous) track has completed and no user input has been provided to select the next track to play
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
    
    // Determines the next track to play when the user has requested the next track
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
    
    // Determines the next track to play when the user has requested the previous track
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
    
    // Determines which track will play next if playlist.continuePlaying() is invoked, if any. This is used to eagerly prep tracks for future playback. Nil return value indicates no track.
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
    
    // Determines which track will play next if playlist.next() is invoked, if any. This is used to eagerly prep tracks for future playback. Nil return value indicates no track.
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
    
    // Determines which track will play next if playlist.previous() is invoked, if any. This is used to eagerly prep tracks for future playback. Nil return value indicates no track.
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
    
    func getRepeatMode() -> RepeatMode {
        return repeatMode
    }
    
    func getShuffleMode() -> ShuffleMode {
        return shuffleMode
    }
    
    func getPersistentState() -> PlaybackSequenceState {
        
        let state = PlaybackSequenceState()
        state.repeatMode = repeatMode
        state.shuffleMode = shuffleMode
        
        return state
    }
}
