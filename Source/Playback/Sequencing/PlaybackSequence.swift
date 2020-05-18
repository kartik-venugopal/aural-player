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
    internal var cursor: Int? = nil
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    private let shuffleSequence: ShuffleSequence = ShuffleSequence(0)
    
    init(_ tracksCount: Int, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
        reset(tracksCount: tracksCount)
    }
    
    var size: Int {
        return tracksCount
    }
    
    // Ends the sequence (i.e. invalidates the cursor)
    func end() {
        cursor = nil
    }
    
    // Resets the sequence with a new size and the first track in the sequence being the given track index
    func reset(tracksCount: Int, newCursor: Int? = nil) {
        
        self.tracksCount = tracksCount
        self.cursor = newCursor
        
        resetShuffleSequence()
    }
    
    // Resets the sequence with the first element in the sequence being the given index
    private func resetShuffleSequence() {

        // If shuffle is on, recompute the shuffle sequence
        if shuffleMode == .on {
            shuffleSequence.resize(size: tracksCount, firstTrackIndex: cursor)
        }
    }
    
    func clear() {
        
        shuffleSequence.clear()
        tracksCount = 0
        cursor = nil
    }
    
    func select(_ index: Int) {
        
        // When a specific index is selected, the sequence is reset
        cursor = index
        resetShuffleSequence()
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
        return setShuffleMode(self.shuffleMode == .on ? .off : .on)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        // Execute this method only if the desired shuffle mode is different from the current shuffle mode.
        guard shuffleMode != self.shuffleMode else {return (repeatMode, shuffleMode)}
        
        self.shuffleMode = shuffleMode
        
        if shuffleMode == .on {
        
            // Can't shuffle and repeat one track
            if repeatMode == .one {
                repeatMode = .off
            }
            
            resetShuffleSequence()
            
        } else {    // Shuffle mode is off
            
            shuffleSequence.clear()
        }
        
        return (repeatMode, shuffleMode)
    }
    
    func subsequent() -> Int? {

        guard tracksCount > 0 else {return nil}
        
        // NOTE - If shuffle is on, it is important to call resetShuffleSequence() or next() here, and update the cursor.
        // Cannot simply return the value from peekSubsequent().
        if shuffleMode == .on {
            
            // If shuffle sequence has ended, just create a new one, and keep going (when repeating all)
            if repeatMode == .all && shuffleSequence.ended() {
                resetShuffleSequence()
            }
            
            cursor = shuffleSequence.next()
            
        } // Shuffle mode is off
        else {
            cursor = peekSubsequent()
        }
        
        return cursor
    }
    
    func peekSubsequent() -> Int? {
        
        guard tracksCount > 0 else {return nil}
        
        switch (repeatMode, shuffleMode) {
            
        // Repeat Off / All, Shuffle Off
        case (.off, .off), (.all, .off):
          
            // Next track sequentially
            if let theCursor = cursor, theCursor < (tracksCount - 1) {
                
                // Has more tracks, pick the next one
                return theCursor + 1
                
            } else {
                
                // If repeating all, loop around to the first track.
                // If not repeating, nothing playing, always return the first one.
                // Else last track reached ... stop playback.
                return repeatMode == .all ? 0 : (cursor == nil ? 0 : nil)
            }
        
        // Repeat One (Shuffle Off implied)
        case (.one, .off):
            
            // Easy, just play the same track again (assume shuffleMode is off)
            return cursor == nil ? 0 : cursor
        
        // Repeat Off / All, Shuffle On
        case (.off, .on), (.all, .on):
           
            // If the sequence is complete (all tracks played), no track
            // Cannot predict next track because sequence will be reset
            return shuffleSequence.peekNext()
            
        default:
            
            return nil
        }
    }
    
    func next() -> Int? {
        
        guard tracksCount > 1, cursor != nil else {return nil}
        
        // NOTE - If shuffle is on, it is important to call resetShuffleSequence() or next() here, and update the cursor.
        // Cannot simply return the value from peekSubsequent().
        if shuffleMode == .on {
            
            // If shuffle sequence has ended, just create a new one, and keep going
            if repeatMode == .all && shuffleSequence.ended() {
                resetShuffleSequence()
            }

            // Pick the next track in the sequence, if the sequence hasn't ended.
            if let next = shuffleSequence.next() {
                cursor = next
                return next
            }
            
        } else if let next = peekNext() {
            
            // NOTE - If the result is nil, don't modify the cursor, because next() should not end the currently playing track if there is one
            cursor = next
            return next
        }
        
        return nil
    }
    
    func peekNext() -> Int? {
        
        guard tracksCount > 1, let theCursor = cursor else {return nil}
        
        if shuffleMode == .on {
            return shuffleSequence.peekNext()
            
        } // Shuffle mode is off
        else {
            return theCursor < (tracksCount - 1) ? theCursor + 1 : (repeatMode == .all ? 0 : nil)
        }
    }
    
    func previous() -> Int? {
        
        guard tracksCount > 1, cursor != nil else {return nil}
        
        if shuffleMode == .on {
            _ = shuffleSequence.previous()
        }

        // NOTE - If the result is nil, don't modify the cursor, because previous() should not end the currently playing track if there is one
        if let previous = peekPrevious() {
            cursor = previous
            return previous
        }
        
        return nil
    }
    
    func peekPrevious() -> Int? {
        
        guard tracksCount > 1, let theCursor = cursor else {return nil}
        
        if shuffleMode == .on {
            return shuffleSequence.peekPrevious()
            
        } // Shuffle mode is off
        else {
            return theCursor > 0 ? theCursor - 1 : (repeatMode == .all ? tracksCount - 1 : nil)
        }
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return (repeatMode, shuffleMode)
    }
}
