//
//  AtomicCounter.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A thread-safe integer counter that safely tracks a value updated concurrently by multiple threads.
///
public final class AtomicCounter<T> where T: SignedInteger {
    
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    private var _value: T
    
    var isNonNegative: Bool {value >= 0}
    var isNonPositive: Bool {value <= 0}
    
    var isPositive: Bool {value > 0}
    var isNegative: Bool {value < 0}
    
    var isZero: Bool {value == 0}
    var isNonZero: Bool {value != 0}
    
    public init(value initialValue: T = 0) {
        _value = initialValue
    }
    
    public var value: T {
        
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
    
    public func decrementAndGet() -> T {
        
        lock.produceValueAfterWait {
            _value.decrementAndGet()
        }
    }
    
    public func decrement() {
        
        lock.executeAfterWait {
            _value.decrement()
        }
    }
    
    public func incrementAndGet() -> T {
        
        lock.produceValueAfterWait {
            _value.incrementAndGet()
        }
    }
    
    public func getAndIncrement() -> T {
        
        lock.produceValueAfterWait {
            
            let valueBeforeIncrement = _value
            _value.increment()
            return valueBeforeIncrement
        }
    }
    
    public func increment() {

        lock.executeAfterWait {
            _value.increment()
        }
    }
    
    public func add(_ addend: T) {

        lock.executeAfterWait {
            _value += addend
        }
    }
}
