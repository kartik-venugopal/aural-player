//
//  GroupedItemRemovalResult.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Base class (not meant to be instantiated) for a track / group removal result.
///
class GroupedItemRemovalResult {
    
    // The group that was removed
    let group: Group
    
    // The index from which the group was removed
    let groupIndex: Int
    
    // The index by which these results will be sorted (for ex, a track index or group index)
    var sortIndex: Int {groupIndex}
    
    init(_ group: Group, _ groupIndex: Int) {
        
        self.group = group
        self.groupIndex = groupIndex
    }
    
    static func compareAscending(_ result1: GroupedItemRemovalResult, _ result2: GroupedItemRemovalResult) -> Bool {
        result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: GroupedItemRemovalResult, _ result2: GroupedItemRemovalResult) -> Bool {
        result1.sortIndex > result2.sortIndex
    }
}
