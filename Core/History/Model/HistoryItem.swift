//
//  HistoryItem.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Represents an item that was played in the past, i.e. a track.
///
class HistoryItem {
    
    var displayName: String
    let key: CompositeKey
    
    var lastEventTime: Date
    var eventCount: Int
    
    init(displayName: String, key: CompositeKey, lastEventTime: Date, eventCount: Int) {
        
        self.displayName = displayName
        self.key = key
        self.lastEventTime = lastEventTime
        self.eventCount = eventCount
    }
    
    func markEvent() {
        
        lastEventTime = Date()
        eventCount.increment()
    }
}
