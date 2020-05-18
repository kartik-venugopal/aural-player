/*
    Encapsulates a pre-computed shuffle sequence to be used to determine the order in which shuffled tracks will be played.
 */

import Foundation

class ShuffleSequence {
    
    // Array of sequence track indexes that constitute the shuffle sequence. This array must always be of the same size as the parent playback sequence
    private var sequence: [Int] = []
    
    // The index, within this sequence, of the currently playing track index. This is NOT a track index. It is an index of an index.
    private var curIndex: Int = -1
    
    private var size: Int {
        return sequence.count
    }
    
    // Recompute the sequence, with a given tracks count
    func resizeAndReshuffle(size: Int, startWith desiredStartValue: Int? = nil) {
        
        print(String(format: "\nResizing shuffle sequence with size: %d and startValue: %@", size, String(describing: desiredStartValue)))
        
        curIndex = desiredStartValue == nil ? -1 : 0
        
        if self.size != size {
            sequence = Array(0..<size)
            print(String(format: "\tDID ACTUALLY resize shuffle sequence with size: %d and startValue: %@", size, String(describing: desiredStartValue)))
        }
        
        // NOTE - If only one track in sequence, no need to do any adjustments.
        guard self.size > 1 else {
            print("\tShuffle sequence now:", sequence, ",cursor:", curIndex)
            return}
        
        shuffle()
        
        if let theStartValue = desiredStartValue, sequence.first != theStartValue, let indexOfStartValue = sequence.firstIndex(of: theStartValue) {

            // Make sure that desiredStartValue is at index 0 in the new sequence.
            sequence.swapAt(0, indexOfStartValue)
        }
        
        print("\tShuffle sequence now:", sequence, ",cursor:", curIndex)
    }
    
    // Shuffle the sequence elements
    private func shuffle() {
        
        guard size > 1 else {return}
        
        print("\nShuffling shuffle sequence ...")
        sequence.shuffle()
    }
    
    // Clear the sequence
    func clear() {
        
        print("\nClearing shuffle sequence ...")
        sequence.removeAll()
        curIndex = -1
    }
    
    // Called when sequence ends. Ensure that the first element of the new sequence is different from the last element of the previous sequence, so that no track is played twice in a row.
    private func sequenceEnded(dontStartWith value: Int) {
        
        print(String(format: "\nShuffle sequence ended dontStartValue: %@", String(describing: value)))
        
        curIndex = -1
        
        // NOTE - If only one track in sequence, no need to do any adjustments.
        guard size > 1 else {return}
        
        shuffle()
        
        if sequence.first == value {
            sequence.swapAt(0, size - 1)
        }
        
        print("\tShuffle sequence now:", sequence, ",cursor:", curIndex)
    }
    
    // Retreat the cursor by one index and retrieve the element at the new index, if available
    func previous() -> Int? {
        let val = hasPrevious() ? sequence[curIndex.decrementAndGet()] : nil
        print("\tShuffle.Previous() ->", curIndex)
        return val
    }
    
    // Advance the cursor by one index and retrieve the element at the new index, if available
    func next(repeatMode: RepeatMode) -> Int? {
        
        if repeatMode == .all, hasEnded {
            sequenceEnded(dontStartWith: sequence[curIndex])
        }
        
        let val = hasNext() ? sequence[curIndex.incrementAndGet()] : nil
        print("\tShuffle.Next() ->", curIndex)
        
        return val
    }
    
    // Retrieve the previous element, if available, without retreating the cursor. This is useful when trying to predict the previous track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekPrevious() -> Int? {
        return hasPrevious() ? sequence[curIndex - 1] : nil
    }
    
    // Retrieve the next element, if available, without advancing the cursor. This is useful when trying to predict the next track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekNext() -> Int? {
        return hasNext() ? sequence[curIndex + 1] : nil
    }
    
    // TODO: This is not being used. Make it used.
    // Insert a new element (new track index) randomly within the sequence, ensuring that it is inserted after the cursor, so that the new element is visited in the future.
    func insertElement(elm: Int) {
        
        // Insert between (cursor + 1) and (sequence count), inclusive
        let min: UInt32 = UInt32(curIndex + 1)
        let max: UInt32 = UInt32(sequence.count)
        
        let insertionPoint = arc4random_uniform(max - min + 1) + min
        sequence.insert(elm, at: Int(insertionPoint))
    }
    
    // Checks if all elements have been visited, i.e. the end of the sequence has been reached
    private var hasEnded: Bool {
        return curIndex == size - 1
    }
    
    // Checks if the cursor is at the beginning of the sequence. NOTE - It is possible to visit elements and return to the start position
    func started() -> Bool {
        return curIndex < 1
    }
    
    // Checks if it is possible to advance the cursor
    func hasNext() -> Bool {
        return size > 0 && curIndex < size - 1
    }
    
    // Checks if it is possible to retreat the cursor
    func hasPrevious() -> Bool {
        return curIndex > 0
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
