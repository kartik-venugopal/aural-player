//
//  Grouping+Support.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

typealias KeyFunction = (Track) -> String

let groupSortByName: GroupComparator = {g1, g2 in
    
    let name1 = g1.name
    let name2 = g2.name
    
    let unknown1 = name1.starts(with: "<Unknown ")
    let unknown2 = name2.starts(with: "<Unknown ")
    
    if unknown1 && !unknown2 {
        return false
    } else if !unknown1 && unknown2 {
        return true
    }
    
    return name1 < name2
}

let artistsKeyFunction: KeyFunction = {track in
    track.artist ?? "<Unknown Artist>"
}

let albumsKeyFunction: KeyFunction = {track in
    track.album ?? "<Unknown Album>"
}

let genresKeyFunction: KeyFunction = {track in
    track.genre ?? "<Unknown Genre>"
}

let decadesKeyFunction: KeyFunction = {track in
    track.decade ?? "<Unknown Decade>"
}

let albumDiscsKeyFunction: KeyFunction = {track in
    
    if let discNumber = track.discNumber {
        return "Disc \(discNumber)"
    }
    
    return "<Unknown Disc>"
}

extension Dictionary {
    
    mutating func append<T>(_ element: T, forKey key: Key) where Value == [T] {
        self[key, default: []].append(element)
    }
}

class GroupingFunction {
    
    let keyFunction: KeyFunction
    let depth: Int
    let subGroupingFunction: GroupingFunction?
    let groupSortOrder: GroupComparator
    let trackSortOrder: TrackComparator
    
    init(keyFunction: @escaping KeyFunction, depth: Int = 0, subGroupingFunction: GroupingFunction? = nil, groupSortOrder: @escaping GroupComparator, trackSortOrder: @escaping TrackComparator) {
        
        self.keyFunction = keyFunction
        self.depth = depth
        
        self.subGroupingFunction = subGroupingFunction
        self.groupSortOrder = groupSortOrder
        self.trackSortOrder = trackSortOrder
    }
    
    // TODO: What is the most suitable place for this logic ???
    func canSubGroup(group: Group) -> Bool {
        
        guard let albumGroup = group as? AlbumGroup else {return true}
        return albumGroup.hasMoreThanOneTotalDisc
    }
    
    static func fromFunctions(_ functions: [(keyFunction: KeyFunction, groupSortFunction: GroupComparator, trackSortFunction: TrackComparator)]) -> GroupingFunction {
        
        if functions.count == 1 {
            return GroupingFunction(keyFunction: functions[0].keyFunction, depth: 1, groupSortOrder: functions[0].groupSortFunction, trackSortOrder: functions[0].trackSortFunction)
        }
        
        var childIndex: Int = functions.lastIndex
        var parentIndex: Int = childIndex - 1
        
        var child = GroupingFunction(keyFunction: functions[childIndex].keyFunction,
                                 depth: childIndex + 1,
                                 groupSortOrder: functions[childIndex].groupSortFunction,
                                 trackSortOrder: functions[childIndex].trackSortFunction)
        
        var parent = GroupingFunction(keyFunction: functions[parentIndex].keyFunction,
                                  depth: parentIndex + 1,
                                  subGroupingFunction: child,
                                  groupSortOrder: functions[parentIndex].groupSortFunction,
                                  trackSortOrder: functions[parentIndex].trackSortFunction)
        
        parentIndex.decrement()
        childIndex.decrement()
        
        while parentIndex >= 0 {
            
            child = parent
            parent = GroupingFunction(keyFunction: functions[parentIndex].keyFunction,
                                      depth: parentIndex + 1,
                                      subGroupingFunction: child,
                                      groupSortOrder: functions[parentIndex].groupSortFunction,
                                      trackSortOrder: functions[parentIndex].trackSortFunction)
            
            parentIndex.decrement()
            childIndex.decrement()
        }
        
        return parent
    }
}
