//
//  PlaybackSequencePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates playback sequence state
 */
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
