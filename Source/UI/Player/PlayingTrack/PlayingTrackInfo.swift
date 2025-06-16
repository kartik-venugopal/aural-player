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
    
    let title: String?
    let artist: String?
    let album: String?
    let art: NSImage?
    let playbackPosition: PlaybackPosition
    let playingChapterTitle: String?
    
    init(track: Track, playbackPosition: PlaybackPosition, playingChapterTitle: String? = nil) {

        self.title = track.title ?? track.defaultDisplayName
        self.artist = track.artist
        self.album = track.album
        self.art = track.art?.originalOrDownscaledImage
        self.playbackPosition = playbackPosition
        self.playingChapterTitle = playingChapterTitle
    }
}
