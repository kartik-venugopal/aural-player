//
//  ConcurrentMap.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Thread-safe **Dictionary**.
///
class ConcurrentMap<T: Hashable, U: Any> {
 
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    
    private var map: [T: U] = [:]
    
    var kvPairs: [T: U] {
        
        lock.produceValueAfterWait {
            
            let copy = map
            return copy
        }
    }
    
    var keys: [T] {
        
        lock.produceValueAfterWait {
            Array(map.keys)
        }
    }
    
    var values: [U] {
        
        lock.produceValueAfterWait {
            Array(map.values)
        }
    }
    
    subscript(_ key: T) -> U? {
        
        get {
            
            lock.produceValueAfterWait {
                map[key]
            }
        }
        
        set (newValue) {
            
            lock.executeAfterWait {
                
                if let theValue = newValue {
                    
                    // newValue is non-nil
                    map[key] = theValue
                    
                } else {
                    
                    // newValue is nil, implying that any existing value should be removed for this key.
                    _ = map.removeValue(forKey: key)
                }
            }
        }
    }
    
    func hasForKey(_ key: T) -> Bool {
        
        lock.produceValueAfterWait {
            map[key] != nil
        }
    }
    
    func remove(_ key: T) -> U? {
        
        lock.produceValueAfterWait {
            map.removeValue(forKey: key)
        }
    }
    
    func removeAll() {
        
        lock.executeAfterWait {
            map.removeAll()
        }
    }
}
