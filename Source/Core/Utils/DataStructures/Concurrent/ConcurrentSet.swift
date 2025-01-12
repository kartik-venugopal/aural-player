//
//  ConcurrentSet.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Thread-safe **Set**.
///
class ConcurrentSet<T: Hashable> {
    
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    private var _set: Set<T> = Set<T>()
    var set: Set<T> {_set}
    
    var count: Int {
        
        lock.produceValueAfterWait {
            _set.count
        }
    }
    
    func contains(_ value: T) -> Bool {
        
        lock.produceValueAfterWait {
            _set.contains(value)
        }
    }
    
    func insert(_ value: T) {
        
        lock.executeAfterWait {
            _set.insert(value)
        }
    }
    
    func performUnion(with values: any Sequence<T>) {
        
        lock.executeAfterWait {
            _set = _set.union(values)
        }
    }
    
    func remove(_ value: T) {
        
        lock.executeAfterWait {
            _set.remove(value)
        }
    }
}
