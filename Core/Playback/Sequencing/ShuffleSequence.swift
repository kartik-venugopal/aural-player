//
//  ShuffleSequence.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a pre-computed shuffle sequence to be used to determine the order
/// in which shuffled tracks will be played. The sequence can flexibly be resized as the
/// corresponding playback sequence changes. Provides functions to iterate through
/// the sequence, e.g. previous/next.
///
/// Example:    For a shuffle sequence with 10 tracks, the sequence may look like:
/// [7, 9, 2, 4, 8, 6, 3, 0, 1, 5]
///
class ShuffleSequence {
    
    // Array of sequence track indexes that constitute the shuffle sequence. This array must always be of the same size as the parent playback sequence
    private(set) var sequence: [Int] = []
    
    var size: Int {
        sequence.count
    }
    
    // The index, within this sequence, of the element representing the currently playing track index. i.e. this is NOT a track index ... it is an index of an index.
    private var curIndex: Int = -1
    
    // MARK: Sequence creation/mutation functions -------------------------------------------------------------------------
    
    // Recompute the sequence, with a given tracks count and starting track index
    func resizeAndReshuffle(size: Int, startWith desiredStartValue: Int? = nil) {
        
        guard size > 0 else {
            
            clear()
            return
        }
        
        curIndex = desiredStartValue == nil ? -1 : 0
        
        // Only recreate the array if the size has changed.
        if self.size != size {
            sequence = Array(0..<size)
        }
        
        // NOTE - If only one track in sequence, no need to do any adjustments.
        guard self.size > 1 else {return}
        
        sequence.shuffle()

        // Make sure that desiredStartValue is at index 0 in the new sequence.
        if let theStartValue = desiredStartValue, sequence.first != theStartValue, let indexOfStartValue = sequence.firstIndex(of: theStartValue) {
            sequence.swapAt(0, indexOfStartValue)
        }
    }
    
    // Called when the sequence ends, to produce a new shuffle sequence.
    // The "dontStartWith" parameter is used to ensure that no track plays twice in a row.
    // i.e. the last element of the previous (ended) sequence should differ from the first
    // element in the new sequence.
    func reShuffle(dontStartWith value: Int) {
        
        curIndex = -1
        
        // NOTE - If only one track in sequence, no need to do any adjustments.
        guard size > 1 else {return}
        
        sequence.shuffle()
        
        // Ensure that the first element of the new sequence is different from
        // the last element of the previous sequence, so that no track is played twice in a row.
        if sequence.first == value {
            sequence.swapAt(0, size - 1)
        }
    }
    
    // Clear the sequence
    func clear() {
        
        sequence.removeAll()
        curIndex = -1
    }
    
    // MARK: Sequence iteration functions and properties -----------------------------------------------------------------
    
    // Returns the value of the element currently pointed to by curIndex (represents the currently playing track, when shuffle is on).
    // nil value indicates that the sequence has either 1 - not yet started, i.e. no track is playing, or 2 - the sequence is empty (which could mean shuffle is off, or no tracks in the playlist).
    var currentValue: Int? {
        (size > 0 && curIndex >= 0 && curIndex < size) ? sequence[curIndex] : nil
    }
    
    // Retreat the cursor by one index and retrieve the element at the new index, if available
    func previous() -> Int? {
        hasPrevious ? sequence[curIndex.decrementAndGet()] : nil
    }
    
    // Advance the cursor by one index and retrieve the element at the new index, if available
    func next(repeatMode: RepeatMode) -> Int? {
        
        // Reshuffle if sequence has ended and need to repeat.
        if repeatMode == .all, hasEnded {
            reShuffle(dontStartWith: sequence[curIndex])
        }
        
        return hasNext ? sequence[curIndex.incrementAndGet()] : nil
    }
    
    // Retrieve the previous element, if available, without retreating the cursor. This is useful when trying to predict the previous track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekPrevious() -> Int? {
        hasPrevious ? sequence[curIndex - 1] : nil
    }
    
    // Retrieve the next element, if available, without advancing the cursor. This is useful when trying to predict the next track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekNext() -> Int? {
        hasNext ? sequence[curIndex + 1] : nil
    }
    
    // Checks if it is possible to retreat the cursor
    var hasPrevious: Bool {
        size > 0 && curIndex > 0
    }
    
    // Checks if it is possible to advance the cursor
    var hasNext: Bool {
        size > 0 && curIndex < size - 1
    }
    
    // Checks if all elements have been visited, i.e. the end of the sequence has been reached
    var hasEnded: Bool {
        size > 0 && curIndex == size - 1
    }
}
