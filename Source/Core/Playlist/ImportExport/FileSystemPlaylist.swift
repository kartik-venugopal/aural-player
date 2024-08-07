//
//  FileSystemPlaylist.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A temporary container for a playlist constructed from an imported playlist file.
///
struct FileSystemPlaylist {

    // The filesystem location of the playlist file referenced by this object
    let file: URL
    
    // URLs of tracks in this playlist
    let tracks: [FileSystemPlaylistTrack]
}

struct FileSystemPlaylistTrack {
    
    let file: URL
    let cueSheetMetadata: CueSheetMetadata?
}

class CueSheetMetadata: Codable {
    
    var chapters: [Chapter]?
    
    // Overall album info
    
    var album: String?
    var albumPerformer: String?
    var genre: String?
    var date: String?
    var discID: String?
    var comment: String?

    // Track-specific info
    
    var performer: String?
    var title: String?
}
