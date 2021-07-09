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

// Specifies the order in which to perform the sort
enum SortOrder {
    
    case ascending
    case descending
}
