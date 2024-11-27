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
import OrderedCollections

///
/// Encapsulates a pre-computed shuffle sequence to be used to determine the order
/// in which shuffled tracks will be played. The sequence can flexibly be resized as the
/// corresponding playback sequence changes. Provides functions to iterate through
/// the sequence, e.g. previous/next.
///
/// Example:    For a shuffle sequence with 10 tracks, the sequence may look like:
/// [7, 9, 2, 4, 8, 6, 3, 0, 1, 5]
///
class ShuffleSequence: PersistentModelObject {
    
    // Array of sequence track indexes that constitute the shuffle sequence. This array must always be of the same size as the parent playback sequence
    private var sequence: OrderedSet<Track> = .init()
    private var playedTracks: OrderedSet<Track> = .init()
    private var isPlaying: Bool = false
    
    func initialize(with tracks: [Track], playingTrack: Track?) {
        
        clear()
        
        isPlaying = playingTrack != nil
        
        guard sequence.count > 1 else {return}
        
        sequence.shuffle()
        
        if let thePlayingTrack = playingTrack, sequence.first != thePlayingTrack, let indexOfPlayingTrack = sequence.firstIndex(of: thePlayingTrack) {
            sequence.swapAt(0, indexOfPlayingTrack)
        }
    }
    
    // The index, within this sequence, of the element representing the currently playing track index. i.e. this is NOT a track index ... it is an index of an index.
//    private var curIndex: Int = -1
    
    // MARK: Sequence creation/mutation functions -------------------------------------------------------------------------
    
//    // Recompute the sequence, with a given tracks count and starting track index
//    func resizeAndReshuffle(size: Int, startWith desiredStartValue: Int? = nil) {
//        
//        guard size > 0 else {
//            
//            clear()
//            return
//        }
//        
////        curIndex = desiredStartValue == nil ? -1 : 0
//        
//        // Only recreate the array if the size has changed.
//        if self.size != size {
//            sequence = Array(0..<size)
//        }
//        
//        // NOTE - If only one track in sequence, no need to do any adjustments.
//        guard self.size > 1 else {return}
//        
//        sequence.shuffle()
//
//        ensureFirstElement(is: desiredStartValue)
//        
//        print("Seq is \(sequence) after resize")
//    }
    
    private func ensureFirstElement(is desiredStartValue: Int?) {
        
        // Make sure that desiredStartValue is at index 0 in the new sequence.
//        if let theStartValue = desiredStartValue, sequence.first != theStartValue, let indexOfStartValue = sequence.firstIndex(of: theStartValue) {
//            sequence.swapAt(0, indexOfStartValue)
//        }
    }
    
    /// 
    /// Called when the sequence has to be re-created, as a result of tracks being moved around, and
    /// a track is currently playing (it then becomes the first track in the new sequence).
    ///
    func reShuffle(startWith desiredStartValue: Int) {
        
//        print("Re-shuffling at size: \(size)")
//        
////        curIndex = 0
//        
//        // NOTE - If only one track in sequence, no need to do any adjustments.
//        guard size > 1 else {return}
//        
//        sequence.shuffle()
//        ensureFirstEleme nt(is: desiredStartValue)
    }
    
    // Called when the sequence ends, to produce a new shuffle sequence.
    // The "dontStartWith" parameter is used to ensure that no track plays twice in a row.
    // i.e. the last element of the previous (ended) sequence should differ from the first
    // element in the new sequence.
    func reShuffle(dontStartWith track: Track) {
        
//        print("Re-shuffling at size: \(size)")
//        
////        curIndex = -1
//        
//        // NOTE - If only one track in sequence, no need to do any adjustments.
//        guard size > 1 else {return}
//        
//        sequence.shuffle()
//        
//        // Ensure that the first element of the new sequence is different from
//        // the last element of the previous sequence, so that no track is played twice in a row.
//        if sequence.first == value {
//            sequence.swapAt(0, size - 1)
//        }
        
        sequence.append(contentsOf: playedTracks)
        guard sequence.count > 1 else {return}
        
        sequence.shuffle()
        
        if sequence.first == track {
            
            let numTracks = sequence.count
            let halfNumTracks = numTracks / 2
            
            // Put the playing track in the second half of the sequence.
            sequence.swapAt(0, Int.random(in: halfNumTracks..<numTracks))
        }
    }
    
    // Clear the sequence
    func clear() {
        
        print("Cleared S.Seq")
        
        sequence.removeAll()
        playedTracks.removeAll()
        isPlaying = false
//        curIndex = -1
    }
    
    // MARK: Sequence iteration functions and properties -----------------------------------------------------------------
    
    // Returns the value of the element currently pointed to by curIndex (represents the currently playing track, when shuffle is on).
    // nil value indicates that the sequence has either 1 - not yet started, i.e. no track is playing, or 2 - the sequence is empty (which could mean shuffle is off, or no tracks in the playlist).
//    var currentValue: Int? {
////        (size > 0 && curIndex >= 0 && curIndex < size) ? sequence[curIndex] : nil
//        -1
//    }
    
    // Retreat the cursor by one index and retrieve the element at the new index, if available
    func previous() -> Track? {
        
        if let previousTrack = playedTracks.last {
            
            sequence.insert(previousTrack, at: 0)
            return previousTrack
        }
        
        return nil
    }
    
    // Advance the cursor by one index and retrieve the element at the new index, if available
    func next(repeatMode: RepeatMode) -> Track? {
        
        if !isPlaying {
            isPlaying = true
            
        } else if repeatMode == .all, hasEnded, let playingTrack = sequence.first {
            
            // Reshuffle if sequence has ended and need to repeat.
            reShuffle(dontStartWith: playingTrack)
            
        } else if sequence.isNonEmpty {
            playedTracks.append(sequence.removeFirst())
        }
        
        return sequence.first
    }
    
    // Retrieve the previous element, if available, without retreating the cursor. This is useful when trying to predict the previous track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekPrevious() -> Track? {
        playedTracks.last
    }
    
    // Retrieve the next element, if available, without advancing the cursor. This is useful when trying to predict the next track in the sequence (to perform some sort of preparation) without actually playing it.
    func peekNext() -> Track? {
        
        isPlaying ?
        (sequence.count > 1 ? sequence[1] : nil) :
        sequence.first
    }
    
    // Checks if it is possible to retreat the cursor
    var hasPrevious: Bool {
        playedTracks.isNonEmpty
    }
    
    // Checks if it is possible to advance the cursor
    var hasNext: Bool {
        isPlaying ? sequence.count > 1 : sequence.isNonEmpty
    }
    
    // Checks if all elements have been visited, i.e. the end of the sequence has been reached
    var hasEnded: Bool {
        isPlaying && sequence.count == 1
    }
    
    var persistentState: ShuffleSequencePersistentState {
        .init(sequence: [], curIndex: -1)
    }
}
