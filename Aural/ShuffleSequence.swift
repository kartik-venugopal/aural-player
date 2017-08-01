/*
    Encapsulates a pre-computed shuffle sequence to be used in conjunction with the playlist when shuffling tracks. Determines the order in which tracks will be shuffled.
 */

import Foundation

class ShuffleSequence {
    
    // Array of playlist track indexes that constitute the shuffle sequence. This array must always be of the same size as the playlist
    var sequence: [Int]
    
    // The currently playing track index
    var cursor: Int
    
    // capacity = number of tracks in playlist
    init(_ capacity: Int) {
        sequence = [Int]()
        cursor = -1
        reset(capacity)
    }
    
    // Shuffle the playlist elements
    private func shuffle() {
        sequence.shuffle()
    }
    
    // Clear the sequence
    func clear() {
        sequence.removeAll()
        cursor = -1
    }
    
    // Recompute the sequence, with a given tracks count
    func reset(_ capacity: Int) {
        
        clear()
        
        if (capacity > 0) {
        
            for i in 0...capacity - 1 {
                sequence.append(i)
            }
            
            shuffle()
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
