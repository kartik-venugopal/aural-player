//
//  ConcurrentMap.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    private(set) var map: [T: U] = [:]
    
    var count: Int {
        map.count
    }
    
    subscript(_ key: T) -> U? {
        
        get {
            
            lock.produceValueAfterWait {
                map[key]
            }
        }
        
        set {
            
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
    
    func bulkAdd(map: [T: U]) {
        
        lock.executeAfterWait {
            
            for (key, value) in map {
                self.map[key] = value
            }
        }
    }
    
    func bulkAddAndMap<V: Any>(map: [T: V], mappingFunction: (V) -> U?) {
        
        lock.executeAfterWait {
            
            for (key, srcValue) in map {
                
                if let value = mappingFunction(srcValue) {
                    self.map[key] = value
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
