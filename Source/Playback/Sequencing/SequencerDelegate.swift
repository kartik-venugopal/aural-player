//
//  SequencerDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate that represents the Sequencer and provides
/// functions to control the playback sequence.
///
/// Acts as a middleman between clients and the Sequencer, providing a simplified
/// interface / facade for clients to control the playback sequence.
///
/// - SeeAlso: `Sequencer`
///
class SequencerDelegate: SequencerDelegateProtocol {
    
    private let sequencer: SequencerProtocol
    
    init(_ sequencer: SequencerProtocol) {
        self.sequencer = sequencer
    }
    
    var currentTrack: Track? {
        return sequencer.currentTrack
    }
    
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        return sequencer.sequenceInfo
    }
    
    func peekSubsequent() -> Track? {
        return sequencer.peekSubsequent()
    }
    
    func peekPrevious() -> Track? {
        return sequencer.peekPrevious()
    }
    
    func peekNext() -> Track? {
        return sequencer.peekNext()
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.repeatAndShuffleModes
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.toggleRepeatMode()
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.setRepeatMode(repeatMode)
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.toggleShuffleMode()
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.setShuffleMode(shuffleMode)
    }
}
