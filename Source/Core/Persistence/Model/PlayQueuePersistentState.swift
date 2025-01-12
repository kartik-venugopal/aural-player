//
//  PlayQueuePersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct PlayQueuePersistentState: Codable {
    
    let tracks: [URL]?
    var cueSheetMetadata: [URL: CueSheetMetadata]?
    
    let repeatMode: RepeatMode?
    let shuffleMode: ShuffleMode?
    
    let history: HistoryPersistentState?
    
    init(tracks: [Track], repeatMode: RepeatMode, shuffleMode: ShuffleMode, history: HistoryPersistentState) {
        
        var files: [URL] = []
        var cueSheetMetadata: [URL: CueSheetMetadata] = [:]
        
        for track in tracks {
            
            files.append(track.file)
            
            if let metadata = track.cueSheetMetadata {
                cueSheetMetadata[track.file] = metadata
            }
        }
        
        self.tracks = files
        self.cueSheetMetadata = cueSheetMetadata
        
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
        
        self.history = history
    }
    
    init(legacyPlaylistPersistentState: LegacyPlaylistPersistentState?, legacyPlaybackSequencePersistentState: LegacyPlaybackSequencePersistentState?, legacyHistoryPersistentState: LegacyHistoryPersistentState?) {
        
        self.tracks = legacyPlaylistPersistentState?.tracks?.map {URL(fileURLWithPath: $0)}
        self.cueSheetMetadata = nil
        self.repeatMode = legacyPlaybackSequencePersistentState?.repeatMode
        self.shuffleMode = legacyPlaybackSequencePersistentState?.shuffleMode
        self.history = HistoryPersistentState(legacyPersistentState: legacyHistoryPersistentState)
    }
    
    mutating func cueSheetMetadata(forFile file: URL) -> CueSheetMetadata? {
        cueSheetMetadata?.removeValue(forKey: file)
    }
}

struct TrackPersistentState: Codable {
    
    let file: URL?
    let cueSheetMetadata: CueSheetMetadata?
}

struct ShuffleSequencePersistentState: Codable {
    
    let sequence: [Int]?
    let playedTracks: [Int]?
}
