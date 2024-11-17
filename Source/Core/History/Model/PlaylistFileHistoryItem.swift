//
//  PlaylistFileHistoryItem.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class PlaylistFileHistoryItem: HistoryItem {
    
    let playlistFile: URL
    
    init(playlistFile: URL, lastEventTime: Date, eventCount: Int = 1) {
        
        self.playlistFile = playlistFile
        super.init(displayName: playlistFile.lastPathComponents(count: 2), 
                   key: Self.key(forPlaylistFile: playlistFile),
                   lastEventTime: lastEventTime, eventCount: eventCount)
    }
    
    static func key(forPlaylistFile playlistFile: URL) -> CompositeKey {
        .init(primaryKey: "playlistFile", secondaryKey: playlistFile.path)
    }
}
