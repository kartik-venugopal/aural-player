//
//  PlaylistHistoryItem.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Managed Playlist (not Imported Playlist)
///
class PlaylistHistoryItem: HistoryItem {
    
    let playlistName: String
    
    init(playlistName: String, addCount: HistoryEventCounter, playCount: HistoryEventCounter) {
        
        self.playlistName = playlistName
        super.init(displayName: playlistName,
                   key: Self.key(forPlaylistNamed: playlistName),
                   addCount: addCount,
                   playCount: playCount)
    }
    
    static func key(forPlaylistNamed playlistName: String) -> CompositeKey {
        .init(primaryKey: "playlist", secondaryKey: playlistName)
    }
}
