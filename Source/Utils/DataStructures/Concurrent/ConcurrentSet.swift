//
//  ConcurrentSet.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ConcurrentSet<T: Hashable> {
    
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    private(set) var set: Set<T> = Set<T>()
    
    func contains(_ value: T) -> Bool {
        
        lock.produceValueAfterWait {
            set.contains(value)
        }
    }
    
    func insert(_ value: T) {
        
        lock.executeAfterWait {
            set.insert(value)
        }
    }
}
