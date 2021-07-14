//
//  GroupedTracksRemovalResult.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the results of removing a set of tracks from a group within a single grouping playlist.
///
class GroupedTracksRemovalResult: GroupedItemRemovalResult {
    
    // Indexes of the removed tracks within their parent group
    let trackIndexesInGroup: IndexSet
    
    init(_ group: Group, _ groupIndex: Int, _ trackIndexesInGroup: IndexSet) {
        
        self.trackIndexesInGroup = trackIndexesInGroup
        super.init(group, groupIndex)
    }
}
