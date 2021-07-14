//
//  ItemMoveResults.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the aggregated results of moving (reordering) a set of tracks / groups within one of the playlist types.
///
struct ItemMoveResults {
    
    // The individual results
    let results: [ItemMoveResult]
    
    // The type of the playlist in which the tracks/groups were moved
    let playlistType: PlaylistType
}

///
/// Base class (not meant to be instantiated) for the result of a single track / group being moved within a single playlist type.
///
class ItemMoveResult {
    
    // Index by which these results will be sorted
    var sortIndex: Int {sourceIndex}
    
    // The old (source) index of the moved item
    let sourceIndex: Int
    
    // The new (destination) index of the moved item
    let destinationIndex: Int
    
    // Whether or not the track/group was moved up within the playlist
    let movedUp: Bool
    
    // Whether or not the track/group was moved down within the playlist
    let movedDown: Bool
    
    init(_ sourceIndex: Int, _ destinationIndex: Int) {
        
        self.sourceIndex = sourceIndex
        self.destinationIndex = destinationIndex
        
        self.movedUp = destinationIndex < sourceIndex
        self.movedDown = !self.movedUp
    }
    
    static func compareAscending(_ result1: ItemMoveResult, _ result2: ItemMoveResult) -> Bool {
        result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: ItemMoveResult, _ result2: ItemMoveResult) -> Bool {
        result1.sortIndex > result2.sortIndex
    }
}
