//
//  TrackMoveResult.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the result of moving a single group either within a group, or within the flat playlist.
///
class TrackMoveResult: ItemMoveResult {
    
    // The parent group, if the move occurred within a grouping playlist, or nil,
    // if the move occurred within the flat playlist
    let parentGroup: Group?
    
    init(_ sourceIndex: Int, _ destinationIndex: Int, _ parentGroup: Group? = nil) {
        
        self.parentGroup = parentGroup
        super.init(sourceIndex, destinationIndex)
    }
    
    static func compareAscending(_ result1: TrackMoveResult, _ result2: TrackMoveResult) -> Bool {
        result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: TrackMoveResult, _ result2: TrackMoveResult) -> Bool {
        result1.sortIndex > result2.sortIndex
    }
}
