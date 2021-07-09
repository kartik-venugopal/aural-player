//
//  SortResults.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

struct SortResults {
    
    let playlistType: PlaylistType

    let tracksSorted: Bool
    
    // These 2 fields are only applicable when tracks are sorted within groups.
    let affectedGroupsScope: GroupsScope?
    let affectedParentGroups: [Group]   // This array will be non-empty only when affectedGroupsScope == .selectedGroups
    
    let groupsSorted: Bool
    
    init(_ playlistType: PlaylistType, _ sort: Sort) {
        
        self.playlistType = playlistType
        
        self.tracksSorted = sort.tracksSort != nil
        self.groupsSorted = sort.groupsSort != nil
        
        self.affectedGroupsScope = sort.tracksSort?.scope
        self.affectedParentGroups = sort.tracksSort?.parentGroups ?? []
    }
}

enum GroupsScope {
    
    case allGroups
    case selectedGroups
}
