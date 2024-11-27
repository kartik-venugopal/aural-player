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
        
        sequence.append(contentsOf: tracks)
        isPlaying = playingTrack != nil
        
        guard sequence.count > 1 else {return}
        
        sequence.shuffle()
        
        if let thePlayingTrack = playingTrack, sequence.first != thePlayingTrack, let indexOfPlayingTrack = sequence.firstIndex(of: thePlayingTrack) {
            sequence.swapAt(0, indexOfPlayingTrack)
        }
        
        print("\nInit Seq (\(sequence.count)), Seq: \(sequence), PTs: \(playedTracks)")
    }
    
    ///
    /// Called when the sequence ends, to produce a new shuffle sequence.
    /// The "dontStartWith" parameter is used to ensure that no track plays twice in a row.
    /// i.e. the last element of the previous (ended) sequence should differ from the first
    /// element in the new sequence.
    ///
    func reShuffle(dontStartWith track: Track) {
        
        sequence.append(contentsOf: playedTracks)
        playedTracks.removeAll()
        
        guard sequence.count > 1 else {return}
        
        sequence.shuffle()
        
        if sequence.first == track {
            
            let numTracks = sequence.count
            let halfNumTracks = numTracks / 2
            
            // Put the playing track in the second half of the sequence.
            sequence.swapAt(0, Int.random(in: halfNumTracks..<numTracks))
        }
        
        print("After re-shuffle, seq is: \(sequence), PTs: \(playedTracks)")
    }
    
    func addTracks(_ tracks: [Track]) {

        // NOTE - Will always be playing when this func is called.
        guard let playingTrack = sequence.first else {return}
        
        // Shuffle everything after the playing track
        
        sequence.append(contentsOf: tracks)
        sequence.shuffle()
        
        // Ensure the playing track is in the first position.
        if sequence.first != playingTrack, let indexOfPlayingTrack = sequence.firstIndex(of: playingTrack) {
            sequence.swapAt(0, indexOfPlayingTrack)
        }
        
        print("\nAdded \(tracks.count) tracks: \(tracks), Seq is now (\(sequence.count)): \(sequence), PTs: \(playedTracks)")
    }
    
    func removeTracks(_ tracks: [Track]) {
        
        sequence.removeItems(tracks)
        playedTracks.removeItems(tracks)
        
        print("\nRemoved \(tracks.count) tracks: \(tracks), Seq is now (\(sequence.count)): \(sequence), PTs: \(playedTracks)")
    }
    
    // Clear the sequence
    func clear() {
        
        print("\nCleared S.Seq")
        
        sequence.removeAll()
        playedTracks.removeAll()
        isPlaying = false
    }
    
    // MARK: Sequence iteration functions and properties -----------------------------------------------------------------
    
    // Retreat the cursor by one index and retrieve the element at the new index, if available
    func previous() -> Track? {
        
        if hasPrevious {
            
            let previousTrack = playedTracks.removeLast()
            sequence.insert(previousTrack, at: 0)
            
            print("\nPrevious(): \(previousTrack) Seq: \(sequence), PTs: \(playedTracks)")
            return previousTrack
        }
        
        print("\nPrevious(): nil")
        return nil
    }
    
    // Advance the cursor by one index and retrieve the element at the new index, if available
    func next(repeatMode: RepeatMode) -> Track? {
        
        if !isPlaying {
            isPlaying = true
            print("\nNext(): \(sequence.first!), Now Playing ... Seq: \(sequence), PTs: \(playedTracks)")
            
        } else if hasEnded {
            
            if repeatMode == .all, let playingTrack = sequence.first {
                // Reshuffle if sequence has ended and need to repeat.
                
                print("\nNext(): hasEnded, re-shuffling !!! Don't start with: \(playingTrack) ...")
                reShuffle(dontStartWith: playingTrack)
                
            } else {
                
                // Sequence ended and will not repeat.
                print("\nNext(): hasEnded !")
                return nil
            }
            
        } else if sequence.isNonEmpty {
            
            playedTracks.append(sequence.removeFirst())
            print("\nNext(): \(sequence.first!) ... Seq: \(sequence), PTs: \(playedTracks)")
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
