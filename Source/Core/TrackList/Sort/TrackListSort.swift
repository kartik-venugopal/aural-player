//
//  TrackListSort.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct TrackListSort {
    
    let fields: [TrackSortField]
    let order: SortOrder
    let comparator: TrackComparator
    
    init(fields: [TrackSortField], order: SortOrder) {
        
        self.fields = fields
        self.order = order
        
        let comparisons = fields.map {$0.comparison}
        var compositeFunction: TrackComparison = comparisons[0]
        
        if comparisons.count > 1 {
            
            for index in 1..<comparisons.count {
                compositeFunction = chainTrackComparisons(compositeFunction, comparisons[index])
            }
        }
        
        self.comparator = order == .ascending ?
        comparisonToAscendingTrackComparator(compositeFunction) :
        comparisonToDescendingTrackComparator(compositeFunction)
    }
}

//struct GroupSort {
//
//    let fields: [GroupSortField]
//    let order: SortOrder
//    
//    let comparator: GroupComparator
//    
//    init(fields: [GroupSortField], order: SortOrder) {
//        
//        self.fields = fields
//        self.order = order
//        
//        let comparisons = fields.map {$0.comparison}
//        var compositeFunction: GroupComparison = comparisons[0]
//        
//        if comparisons.count > 1 {
//            
//            for index in 1..<comparisons.count {
//                compositeFunction = chainGroupComparisons(compositeFunction, comparisons[index])
//            }
//        }
//        
//        self.comparator = order == .ascending ?
//        comparisonToAscendingGroupComparator(compositeFunction) :
//        comparisonToDescendingGroupComparator(compositeFunction)
//    }
//}
//
//struct GroupedTrackListSort {
//    
//    let groupSort: GroupSort?
//    let trackSort: TrackListSort?
//    
//    init(groupSort: GroupSort? = nil, trackSort: TrackListSort? = nil) {
//        
//        self.groupSort = groupSort
//        self.trackSort = trackSort
//    }
//}

///
/// Specifies the order in which to perform a sort.
///
enum SortOrder {
    
    case ascending
    case descending
}
