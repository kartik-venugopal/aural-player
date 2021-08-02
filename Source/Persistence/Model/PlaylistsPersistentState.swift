//
//  PlaylistPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for all playlists.
///
/// - SeeAlso:  `PlaylistsManager`
///
struct PlaylistsPersistentState: Codable {
    
    // List of track files (as URL paths).
    let tracks: [URLPath]?
    let groupingPlaylists: [String: GroupingPlaylistPersistentState]?
    
    let userPlaylists: [PlaylistPersistentState]?
}

///
/// Persistent state for a single playlist.
///
/// - SeeAlso:  `Playlist`
///
struct PlaylistPersistentState: Codable {
    
    let name: String?
    
    // List of track files (as URL paths).
    let tracks: [URLPath]?
    let groupingPlaylists: [String: GroupingPlaylistPersistentState]?
}
