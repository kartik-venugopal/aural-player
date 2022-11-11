//
//  GroupRemovalResult.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the result of removing a single group from a single grouping playlist.
///
class GroupRemovalResult: GroupedItemRemovalResult {
    
    static func compareAscending(_ result1: GroupRemovalResult, _ result2: GroupRemovalResult) -> Bool {
        result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: GroupRemovalResult, _ result2: GroupRemovalResult) -> Bool {
        result1.sortIndex > result2.sortIndex
    }
}
