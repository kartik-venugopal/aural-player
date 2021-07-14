//
//  ImportedPlaylist.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A temporary container for a playlist constructed from an imported playlist file.
///
struct ImportedPlaylist {

    // The filesystem location of the playlist file referenced by this object
    let file: URL
    
    // URLs of tracks in this playlist
    let tracks: [URL]
}
