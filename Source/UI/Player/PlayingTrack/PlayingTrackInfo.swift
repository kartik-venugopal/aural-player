//
//  PlayingTrackInfo.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Encapsulates displayed information for the currently playing track.
struct PlayingTrackInfo {
    
    let track: Track
    let playingChapterTitle: String?
    
    init(track: Track, playingChapterTitle: String? = nil) {
        
        self.track = track
        self.playingChapterTitle = playingChapterTitle
    }
    
    var art: NSImage? {
        track.art?.originalOrDownscaledImage
    }
    
    var artist: String? {
        track.artist
    }
    
    var album: String? {
        track.album
    }
    
    var title: String? {
        track.title ?? track.defaultDisplayName
    }
}
