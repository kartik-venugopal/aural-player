/*
    Encapsulates a pre-computed shuffle sequence to be used to determine the order in which shuffled tracks will be played.
 */

import Foundation

class ShuffleSequence {
    
    // Array of sequence track indexes that constitute the shuffle sequence. This array must always be of the same size as the parent playback sequence
    private var sequence: [Int] = []
    
    // The index, within this sequence, of the currently playing track index. This is NOT a track index. It is an index of an index.
    private var cursor: Int = -1
    
    // size = number of tracks in sequence
    init(_ size: Int) {
        resize(size: size)
    }
    
    // Shuffle the sequence elements
    private func shuffle() {
        
        print("Shuffling shuffle sequence ...")
        
        sequence.shuffle()
    }
    
    // Clear the sequence
    func clear() {
        
        print("Clearing shuffle sequence ...")
        
        sequence.removeAll()
        cursor = -1
    }
    
    // Recompute the sequence, with a given tracks count
    func resize(size: Int, firstTrackIndex: Int? = nil) {
        
        print("Resizing shuffle sequence with size:", size)
        
        clear()
        
        sequence = Array(0..<size)
        shuffle()
        
        if let theFirstElement = firstTrackIndex, let indexOfFirstElement = sequence.firstIndex(of: theFirstElement) {

            // Make sure that firstTrackIndex is at index 0 in the new sequence.
            sequence.swapAt(0, indexOfFirstElement)
            
            // Advance the cursor once, because the first track in the sequence has already been played back
            _ = next()
        }
        
        // TODO: Add a func reshuffle() which will not change the capacity, only reshuffle the elements and ensure the following uniqueness.
        
        // TODO: Ensure that the first element of the new sequence is different from the last element of the previous sequence, so that no track is played twice in a row
        
//        let lastSequenceLastElement = shuffleSequence.sequence.last
//        let lastSequenceCount = shuffleSequence.sequence.count
//
//        shuffleSequence.reset(capacity: tracksCount)
//

//        if (lastSequenceCount > 1 && lastSequenceLastElement != nil && tracksCount > 1) {
//            if (shuffleSequence.peekNext() == lastSequenceLastElement) {
//                swapFirstTwoShuffleSequenceElements()
//            }
//        }
//
//        // Make sure that the first track does not match the currently playing track
//        if (tracksCount > 1 && shuffleSequence.peekNext() == cursor) {
//            swapFirstTwoShuffleSequenceElements()
//        }
    }
    
    func reshuffle(_ previousCursor: Int) {
        
    }
    
    // Retreat the cursor by one index and retrieve the element at the new index, if available
    func previous() -> Int? {
        return hasPrevious() ? sequence[cursor.decrementAndGet()] : nil
    }
    
    // Advance the cursor by one index and retrieve the element at the new index, if available
    func next() -> Int? {
        return hasNext() ? sequence[cursor.incrementAndGet()] : nil
    }
    
    // Retrieve the previous element, if available, without retreating the cursor. This is useful when trying to predict the previous track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekPrevious() -> Int? {
        return hasPrevious() ? sequence[cursor - 1] : nil
    }
    
    // Retrieve the next element, if available, without advancing the cursor. This is useful when trying to predict the next track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekNext() -> Int? {
        return hasNext() ? sequence[cursor + 1] : nil
    }
    
    // TODO: This is not being used. Make it used.
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
        return sequence.count > 0 && cursor < sequence.count - 1
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
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}
