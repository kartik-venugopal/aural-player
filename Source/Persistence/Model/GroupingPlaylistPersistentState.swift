//
//  GroupingPlaylistPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Persistent state for a single grouping / hierarchical playlist.
///
/// - SeeAlso:  `GroupingPlaylist`
///
struct GroupingPlaylistPersistentState: Codable {
    
    let type: PlaylistType?
    let groups: [GroupPersistentState]?
}

///
/// Persistent state for a single group within a grouping / hierarchical playlist.
///
/// - SeeAlso:  `Group`
///
struct GroupPersistentState: Codable {
    
    let name: String?
    let tracks: [URLPath]?
}

extension GroupingPlaylist: PersistentModelObject {
    
    var persistentState: GroupingPlaylistPersistentState {
        GroupingPlaylistPersistentState(type: self.playlistType, groups: self.groups.map {$0.persistentState})
    }
}

extension Group: PersistentModelObject {
    
    var persistentState: GroupPersistentState {
        GroupPersistentState(name: self.name, tracks: self.tracks.map {$0.file.path})
    }
}
