//
//  AtomicBool.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A thread-safe boolean value.
///
public final class AtomicBool {
    
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    private var _value: Bool
    
    public init(value initialValue: Bool = false) {
        _value = initialValue
    }
    
    func setTrue() {
        self.value = true
    }
    
    func setFalse() {
        self.value = false
    }

    func setValue(_ value: Bool) {
        self.value = value
    }
    
    public var value: Bool {
        
        get {
            
            lock.produceValueAfterWait {
                _value
            }
        }
        
        set {
            
            lock.executeAfterWait {
                _value = newValue
            }
        }
    }
}
