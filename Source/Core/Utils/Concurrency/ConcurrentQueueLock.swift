//
// ConcurrentQueueLock.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class ConcurrentQueueLock {
    
    private let resourceName: String
    private let qos: DispatchQoS
    private lazy var queue = DispatchQueue(label: "ConcurrentQueueLock queue for '\(resourceName)'", qos: self.qos, attributes: .concurrent)
    
    init(resourceName: String, qos: DispatchQoS = .userInitiated) {
        
        self.resourceName = resourceName
        self.qos = qos
    }
    
    func read<T>(execute work: () -> T) -> T {
        
        queue.sync {
            work()
        }
    }
    
    func write(execute work: @escaping () -> ()) {
        
        queue.async(flags: .barrier) {
            work()
        }
    }
}
