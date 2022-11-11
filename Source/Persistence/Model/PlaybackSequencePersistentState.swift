//
//  PlaybackSequencePersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the app's playback sequence.
///
/// - SeeAlso:  `PlaybackSequence`
///
struct PlaybackSequencePersistentState: Codable {
    
    let repeatMode: RepeatMode?
    let shuffleMode: ShuffleMode?
}

extension Sequencer: PersistentModelObject {
    
    var persistentState: PlaybackSequencePersistentState {
        
        let modes = sequence.repeatAndShuffleModes
        return PlaybackSequencePersistentState(repeatMode: modes.repeatMode, shuffleMode: modes.shuffleMode)
    }
}
