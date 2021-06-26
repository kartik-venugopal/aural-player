//
//  ConcurrentCompositeKeyMap.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class ConcurrentCompositeKeyMap<T: Hashable, U: Any> {
    
    private var map: CompositeKeyMap<T, U> = CompositeKeyMap()
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    
    subscript(_ key1: T, _ key2: T) -> U? {
        
        get {
            
            lock.produceValueAfterWait {
                map[key1, key2]
            }
        }
        
        set {
            
            lock.executeAfterWait {
                map[key1, key2] = newValue
            }
        }
    }
    
    var entries: [(T, T, U)] {
        
        lock.produceValueAfterWait {
            return map.entries
        }
    }
    
    func removeAll() {
        
        lock.executeAfterWait {
            map.removeAll()
        }
    }
}
