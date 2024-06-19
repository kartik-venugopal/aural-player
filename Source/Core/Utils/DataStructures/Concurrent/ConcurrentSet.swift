//
//  ConcurrentSet.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var count: Int {_set.count}
    
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
}
