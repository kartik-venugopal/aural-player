//
//  FavoriteTrack.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FavoriteTrack: Favorite {
    
    let track: Track
    
    /// Hack that's required because a track's displayName can change (once metadata is loaded).
    /// So, we need this to be computed on-the-fly.
    override var name: String {
        
        get {track.displayName}
        set {}
    }
    
    override var key: String {
        track.file.path
    }
    
    init(track: Track) {
        
        self.track = track
        super.init(name: track.displayName)
    }
}
