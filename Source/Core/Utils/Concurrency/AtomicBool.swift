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
class AtomicBool {
    
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    private var _value: Bool
    
    init(value initialValue: Bool = false) {
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
    
    var value: Bool {
        
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
    
    var isTrue: Bool {
        
        lock.produceValueAfterWait {
            _value
        }
    }
    
    var isFalse: Bool {
        
        lock.produceValueAfterWait {
            _value == false
        }
    }
}
