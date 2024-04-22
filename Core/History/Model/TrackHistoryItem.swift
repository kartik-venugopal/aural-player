//
//  TrackHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class TrackHistoryItem: HistoryItem {
    
    let track: Track
    
    /// Hack that's required because a track's displayName can change (once metadata is loaded).
    /// So, we need this to be computed on-the-fly.
    override var displayName: String {
        
        get {track.displayName}
        set {}
    }
    
    init(track: Track, lastEventTime: Date, eventCount: Int = 1) {
        
        self.track = track
        super.init(displayName: track.displayName,
                   key: Self.key(forTrack: track),
                   lastEventTime: lastEventTime, eventCount: eventCount)
    }
    
    static func key(forTrack track: Track) -> CompositeKey {
        .init(primaryKey: "track", secondaryKey: track.file.path)
    }
}
