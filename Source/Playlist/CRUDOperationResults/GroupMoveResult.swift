//
//  GroupMoveResult.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the result of moving a single group within a single playlist type.
///
class GroupMoveResult: ItemMoveResult {
    
    static func compareAscending(_ result1: GroupMoveResult, _ result2: GroupMoveResult) -> Bool {
        result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: GroupMoveResult, _ result2: GroupMoveResult) -> Bool {
        result1.sortIndex > result2.sortIndex
    }
}
