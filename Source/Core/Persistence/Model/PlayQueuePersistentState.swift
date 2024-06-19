//
//  PlayQueuePersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct PlayQueuePersistentState: Codable {
    
    let tracks: [URL]?
    
    let repeatMode: RepeatMode?
    let shuffleMode: ShuffleMode?
    
    let history: HistoryPersistentState?
    
    init(tracks: [URL], repeatMode: RepeatMode, shuffleMode: ShuffleMode, history: HistoryPersistentState) {
        
        self.tracks = tracks
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
        self.history = history
    }
    
    init(legacyPlaylistPersistentState: LegacyPlaylistPersistentState?, legacyPlaybackSequencePersistentState: LegacyPlaybackSequencePersistentState?, legacyHistoryPersistentState: LegacyHistoryPersistentState?) {
        
        self.tracks = legacyPlaylistPersistentState?.tracks?.map {URL(fileURLWithPath: $0)}
        self.repeatMode = legacyPlaybackSequencePersistentState?.repeatMode
        self.shuffleMode = legacyPlaybackSequencePersistentState?.shuffleMode
        self.history = HistoryPersistentState(legacyPersistentState: legacyHistoryPersistentState)
    }
}
