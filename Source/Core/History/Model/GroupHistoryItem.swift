//
//  GroupHistoryItem.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class GroupHistoryItem: HistoryItem {
    
    let groupName: String
    let groupType: GroupType
    
    init(groupName: String, groupType: GroupType, addCount: HistoryEventCounter, playCount: HistoryEventCounter) {
        
        self.groupName = groupName
        self.groupType = groupType
        
        super.init(displayName: groupName,
                   key: Self.key(forGroupName: groupName, andType: groupType),
                   addCount: addCount,
                   playCount: playCount)
    }
    
    static func key(forGroupName groupName: String, andType groupType: GroupType) -> CompositeKey {
        .init(primaryKey: "group", secondaryKey: "\(groupType.rawValue)_\(groupName)")
    }
}
