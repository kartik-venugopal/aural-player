//
//  FileSystemPlaylist.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    var albumArtist: String?
    var genre: String?
    var date: String?
    var discID: String?
    var comment: String?
    
    var replayGain: ReplayGain?
    
    // Track-specific info
    
    var title: String?
    var artist: String?
    var composer: String?
    
    // Auxiliary info
    
    var songwriter: String?
    var arranger: String?
    var message: String?
    
    lazy var auxiliaryMetadata: [String: String] = {
        
        var metadata: [String: String] = [:]
        
        if let songwriter = self.songwriter {
            metadata["Songwriter"] = songwriter
        }
        
        if let arraner = self.arranger {
            metadata["Arranger"] = arranger
        }
        
        if let message = self.message {
            metadata["Message"] = message
        }
        
        return metadata
    }()
}
