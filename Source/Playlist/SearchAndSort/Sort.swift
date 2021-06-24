//
//  Sort.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Options for performing a sort on the playlist
 */

import Cocoa

class Sort {
    
    var tracksSort: TracksSort?
    var groupsSort: GroupsSort?
    
    func withTracksSort(_ sort: TracksSort) -> Sort {
        self.tracksSort = sort
        return self
    }
    
    func withGroupsSort(_ sort: GroupsSort) -> Sort {
        self.groupsSort = sort
        return self
    }
}

class GroupsSort {
    
    var fields: [SortField] = [.name]
    var order: SortOrder = .ascending
    
    func withFields(_ fields: SortField...) -> GroupsSort {
        self.fields = fields
        return self
    }
    
    func withOrder(_ order: SortOrder) -> GroupsSort {
        self.order = order
        return self
    }
}

class TracksSort {
    
    var fields: [SortField] = [.name]
    var order: SortOrder = .ascending
    
    // These 2 fields are used only when sorting tracks within groups
    var scope: GroupsScope = .allGroups
    var parentGroups: [Group] = []
    
    var options: [TracksSortOptions] = [.useNameIfNoMetadata]
    
    func withFields(_ fields: SortField...) -> TracksSort {
        self.fields = fields
        return self
    }
    
    func withOrder(_ order: SortOrder) -> TracksSort {
        self.order = order
        return self
    }
    
    func withScope(_ scope: GroupsScope) -> TracksSort {
        self.scope = scope
        return self
    }
    
    func withParentGroups(_ groups: [Group]) -> TracksSort {
        self.parentGroups = groups
        return self
    }
    
    func withNoOptions() -> TracksSort {
        self.options = []
        return self
    }
    
    func withOptions(_ options: TracksSortOptions...) -> TracksSort {
        self.options = options
        return self
    }
}

enum TracksSortOptions {
    
    case useNameIfNoMetadata
}

// Specifies which field is used as sort criteria
enum SortField {
    
    case name
    case duration
    case artist
    case album
    case discNumberAndTrackNumber
}

// Specifies the order in which to perform the sort
enum SortOrder {
    
    case ascending
    case descending
}

enum GroupsScope {
    
    case allGroups
    case selectedGroups
}

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
