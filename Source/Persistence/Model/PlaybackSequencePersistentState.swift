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
class PlaybackSequencePersistentState: PersistentStateProtocol {
    
    let repeatMode: RepeatMode?
    let shuffleMode: ShuffleMode?
    
    init(repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
    }
    
    required init?(_ map: NSDictionary) {
        
        self.repeatMode = map.enumValue(forKey: "repeatMode", ofType: RepeatMode.self)
        self.shuffleMode = map.enumValue(forKey: "shuffleMode", ofType: ShuffleMode.self)
    }
}

extension Sequencer: PersistentModelObject {
    
    var persistentState: PlaybackSequencePersistentState {
        
        let modes = sequence.repeatAndShuffleModes
        return PlaybackSequencePersistentState(repeatMode: modes.repeatMode, shuffleMode: modes.shuffleMode)
    }
}
