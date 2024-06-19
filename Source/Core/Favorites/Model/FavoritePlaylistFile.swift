//
//  FavoritePlaylistFile.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FavoritePlaylistFile: Favorite {
    
    let playlistFile: URL
    
    override var key: String {
        playlistFile.path
    }
    
    init(playlistFile: URL) {
        
        self.playlistFile = playlistFile
        super.init(name: playlistFile.lastPathComponent)
    }
}
