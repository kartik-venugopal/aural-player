//
//  SequencerDelegateProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate that represents the Sequencer and provides
/// functions to control the playback sequence.
///
/// Acts as a middleman between clients and the Sequencer, providing a simplified
/// interface / facade for clients to control the playback sequence.
///
/// - SeeAlso: `Sequencer`
///
protocol SequencerDelegateProtocol: SequencerInfoDelegateProtocol {
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
}
