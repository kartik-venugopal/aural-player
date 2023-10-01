//
//  UnsafeBuffer.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class UnsafeBuffer<T> {
    
    let capacity: Int
    private(set) lazy var pointer: UnsafeMutablePointer<T> = .allocate(capacity: capacity)
    
    init(ofCapacity capacity: Int) {
        self.capacity = capacity
    }
    
    subscript(index: Int) -> T {
        
        get {
            pointer[index]
        }
        
        set {
            pointer[index] = newValue
        }
    }
    
    deinit {
        pointer.deallocate()
    }
}
