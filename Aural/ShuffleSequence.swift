/*
    Encapsulates a pre-computed shuffle sequence to be used to determine the order in which shuffled tracks will be played.
 */

import Foundation

class ShuffleSequence {
    
    // Array of sequence track indexes that constitute the shuffle sequence. This array must always be of the same size as the parent playback sequence
    var sequence: [Int]
    
    // The index, within this sequence, of the currently playing track index. This is NOT a track index. It is an index of an index.
    private var cursor: Int
    
    // capacity = number of tracks in sequence
    init(_ capacity: Int) {
        
        sequence = [Int]()
        cursor = -1
        reset(capacity: capacity)
    }
    
    // Shuffle the sequence elements
    private func shuffle() {
        sequence.shuffle()
    }
    
    // Clear the sequence
    func clear() {
        sequence.removeAll()
        cursor = -1
    }
    
    // Recompute the sequence, with a given tracks count
    func reset(capacity: Int) {
        
        clear()
        
        if (capacity > 0) {
        
            for i in 0...capacity - 1 {
                sequence.append(i)
            }
            
            shuffle()
        }
    }
    
    // Recompute the sequence, with the specified track index being the first element in the new sequence
    func reset(capacity: Int, firstTrackIndex: Int) {
        
        clear()
        
        if (capacity > 0) {
            
            if (firstTrackIndex > 0) {
                for i in 0 ... (firstTrackIndex - 1) {
                    sequence.append(i)
                }
            }
            
            if (firstTrackIndex < capacity - 1) {
                for i in (firstTrackIndex + 1) ... (capacity - 1) {
                    sequence.append(i)
                }
            }
            
            shuffle()
            
            // Insert the specified first track index at index 0, making it the first element in the new sequence
            sequence.insert(firstTrackIndex, at: 0)
            
            // Advance the cursor once, because the first track in the sequence has already been played back
            _ = next()
        }
    }
    
    // Advance the cursor by one index and retrieve the element at the new index, if available
    func next() -> Int? {
        
        if (hasNext()) {
            cursor += 1
            return sequence[cursor]
        }
        
        return nil
    }
    
    // Retrieve the next element, if available, without advancing the cursor. This is useful when trying to predict the next track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekNext() -> Int? {
        
        if (hasNext()) {
            return sequence[cursor + 1]
        }
        
        return nil
    }
    
    // Retrieve the previous element, if available, without retreating the cursor. This is useful when trying to predict the previous track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekPrevious() -> Int? {
        
        if (hasPrevious()) {
            return sequence[cursor - 1]
        }
        
        return nil
    }
    
    // Retreat the cursor by one index and retrieve the element at the new index, if available
    func previous() -> Int? {
        
        if (hasPrevious()) {
            cursor -= 1
            return sequence[cursor]
        }
        
        return nil
    }
    
    // Insert a new element (new track index) randomly within the sequence, ensuring that it is inserted after the cursor, so that the new element is visited in the future.
    func insertElement(elm: Int) {
        
        // Insert between (cursor + 1) and (sequence count), inclusive
        let min: UInt32 = UInt32(cursor + 1)
        let max: UInt32 = UInt32(sequence.count)
        
        let insertionPoint = arc4random_uniform(max - min + 1) + min
        sequence.insert(elm, at: Int(insertionPoint))
    }
    
    // Checks if all elements have been visited, i.e. the end of the sequence has been reached
    func ended() -> Bool {
        return cursor == sequence.count - 1
    }
    
    // Checks if the cursor is at the beginning of the sequence. NOTE - It is possible to visit elements and return to the start position
    func started() -> Bool {
        return cursor < 1
    }
    
    // Checks if it is possible to advance the cursor
    func hasNext() -> Bool {
        return cursor < sequence.count - 1
    }
    
    // Checks if it is possible to retreat the cursor
    func hasPrevious() -> Bool {
        return cursor > 0
    }
}

// Shuffles a collection using the Fisher-Yates algorithm
extension MutableCollection where Indices.Iterator.Element == Index {
    
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}
