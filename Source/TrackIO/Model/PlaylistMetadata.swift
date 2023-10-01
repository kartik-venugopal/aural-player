//
//  PlaylistMetadata.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for all metadata required for a track to be displayed within the playlist.
///
/// This is considered the most essential type of metadata and is loaded immediately when a track is added to the playlist.
///
/// The artist / album / genre fields help the playlist categorize tracks into groups also participate in searching and sorting.
///
struct PlaylistMetadata {
    
    var title: String?
    
    var artist: String?
    var albumArtist: String?
    var performer: String?
    
    var album: String?
    var genre: String?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var year: Int?
    
    var duration: Double = 0
    var durationIsAccurate: Bool = false
    
    var isProtected: Bool?
    
    var chapters: [Chapter] = []
}
