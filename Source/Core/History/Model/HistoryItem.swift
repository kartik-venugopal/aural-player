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
    
    var addCount: HistoryEventCounter
    var playCount: HistoryEventCounter
    
    init(displayName: String, key: CompositeKey, addCount: HistoryEventCounter, playCount: HistoryEventCounter) {
        
        self.displayName = displayName
        self.key = key
        
        self.addCount = addCount
        self.playCount = playCount
    }
    
    func markAddEvent() {
        addCount.markEvent()
    }
    
    func markPlayEvent() {
        playCount.markEvent()
    }
}

class HistoryEventCounter {
    
    var lastEventTime: Date? = nil
    var eventCount: Int = 0
    
    func markEvent() {
        
        lastEventTime = Date()
        eventCount.increment()
    }
    
    static func createWithFirstEvent() -> HistoryEventCounter {
        
        let instance = HistoryEventCounter()
        
        instance.lastEventTime = Date()
        instance.eventCount = 1
        
        return instance
    }
}
