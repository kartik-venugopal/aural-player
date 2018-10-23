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
    var scope: GroupsScope = .allGroups     // Used only when sorting tracks within groups
    
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
