//
//  GroupingPlaylistPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class GroupingPlaylistPersistentState: PersistentStateProtocol {
    
    let type: String
    let groups: [GroupPersistentState]?
    
    init(type: String, groups: [GroupPersistentState]) {
        
        self.type = type
        self.groups = groups
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let type = map.nonEmptyStringValue(forKey: "type") else {return nil}
        
        self.type = type
        self.groups = map.persistentObjectArrayValue(forKey: "groups", ofType: GroupPersistentState.self)
    }
}

class GroupPersistentState: PersistentStateProtocol {
    
    let name: String

    // List of track files
    let tracks: [URL]
    
    init(name: String, tracks: [URL]) {
        
        self.name = name
        self.tracks = tracks
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let tracks = map.urlArrayValue(forKey: "tracks") else {return nil}
        
        self.name = name
        self.tracks = tracks
    }
}

extension GroupingPlaylist: PersistentModelObject {
    
    var persistentState: GroupingPlaylistPersistentState {
        GroupingPlaylistPersistentState(type: self.playlistType.rawValue, groups: self.groups.map {$0.persistentState})
    }
}

extension Group: PersistentModelObject {
    
    var persistentState: GroupPersistentState {
        GroupPersistentState(name: self.name, tracks: self.tracks.map {$0.file})
    }
}
