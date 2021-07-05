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

/*
 Encapsulates playlist state
 */
struct PlaylistPersistentState: Codable {
    
    // List of track files
    let tracks: [URL]?
    let groupingPlaylists: [PlaylistType: GroupingPlaylistPersistentState]?
}
