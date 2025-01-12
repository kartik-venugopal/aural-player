//
//  HistoryItem.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    var lastEventTime: Date? {
        
        if let lastAddTime = addCount.lastEventTime {
            
            if let lastPlayTime = playCount.lastEventTime {
                return max(lastAddTime, lastPlayTime)
            } else {
                return lastAddTime
            }
            
        } else {
            return playCount.lastEventTime
        }
    }
    
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
    
    init() {}
    
    static func createWithFirstEvent() -> HistoryEventCounter {
        
        let instance = HistoryEventCounter()
        
        instance.lastEventTime = Date()
        instance.eventCount = 1
        
        return instance
    }
    
    init?(persistentState: HistoryEventCounterPersistentState?) {
        
        guard let persistentState else {return nil}
        
        self.lastEventTime = persistentState.lastEventTime
        self.eventCount = persistentState.eventCount ?? 0
    }
}
