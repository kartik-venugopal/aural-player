import Foundation

///
/// A thread-safe integer counter that safely tracks a value updated concurrently by multiple threads.
///
public final class AtomicCounter<T> where T: SignedInteger {
    
    private let semaphore = DispatchSemaphore(value: 1)
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
            semaphore.wait()
            defer { semaphore.signal() }
            return _value
        }
        
        set {
            semaphore.wait()
            defer { semaphore.signal() }
            _value = newValue
        }
    }
    
    public func decrementAndGet() -> T {
        
        semaphore.wait()
        defer { semaphore.signal() }
        _value -= 1
        return _value
    }
    
    public func decrement() {
        
        semaphore.wait()
        defer { semaphore.signal() }
        _value -= 1
    }
    
    public func incrementAndGet() -> T {
        
        semaphore.wait()
        defer { semaphore.signal() }
        _value += 1
        return _value
    }
    
    public func increment() {
        
        semaphore.wait()
        defer { semaphore.signal() }
        _value += 1
    }
    
    public func add(_ addend: T) {
        
        semaphore.wait()
        defer { semaphore.signal() }
        _value += addend
    }
}

///
/// A thread-safe boolean value.
///
public final class AtomicBool {
    
    private let lock = DispatchSemaphore(value: 1)
    private var _value: Bool
    
    public init(value initialValue: Bool = false) {
        _value = initialValue
    }
    
    func setValue(_ value: Bool) {
        self.value = value
    }
    
    public var value: Bool {
        
        get {
            
            lock.wait()
            defer { lock.signal() }
            return _value
        }
        
        set {
            
            lock.wait()
            defer { lock.signal() }
            _value = newValue
        }
    }
}
