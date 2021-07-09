//
//  TracksSort.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

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
