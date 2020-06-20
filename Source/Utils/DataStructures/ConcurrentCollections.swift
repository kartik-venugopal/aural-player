import Foundation

class ConcurrentMap<T: Hashable, U: Any> {
    
    private let syncQueue: DispatchQueue
    private var map: [T: U] = [:]
    
    init(_ id: String) {
        syncQueue = DispatchQueue(label: id, attributes: .concurrent)
    }
    
    var kvPairs: [T: U] {
        
        let copy = map
        return copy
    }
    
    var keys: [T] {
        return Array(map.keys)
    }
    
    var values: [U] {
        return Array(map.values)
    }
    
    subscript(_ key: T) -> U? {
        
        get {
            
            var value: U? = nil
            
            syncQueue.sync(flags: .barrier) {
                value = map[key]
            }
            
            return value
        }
        
        set (newValue) {
            
            if let theValue = newValue {
                
                // newValue is non-nil
                syncQueue.sync(flags: .barrier) {
                    map[key] = theValue
                }
                
            } else {
                
                // newValue is nil, implying that any existing value should be removed for this key.
                _ = remove(key)
            }
        }
    }
    
    func hasForKey(_ key: T) -> Bool {
        
        var hasValue: Bool = false
        
        syncQueue.sync(flags: .barrier) {
            hasValue = map[key] != nil
        }
        
        return hasValue
    }
    
    func remove(_ key: T) -> U? {
        
        var removedValue: U? = nil
        
        syncQueue.sync(flags: .barrier) {
            removedValue = map.removeValue(forKey: key)
        }
        
        return removedValue
    }
    
    func removeAll() {
        
        syncQueue.sync(flags: .barrier) {
            map.removeAll()
        }
    }
}

class ConcurrentSet<T: Hashable> {
    
    private let syncQueue: DispatchQueue
    private(set) var set: Set<T> = Set<T>()
    
    init(_ id: String) {
        syncQueue = DispatchQueue(label: id, attributes: .concurrent)
    }
    
    func contains(_ value: T) -> Bool {
        
        var hasValue: Bool = false
        
        syncQueue.sync(flags: .barrier) {
            hasValue = set.contains(value)
        }
        
        return hasValue
    }
    
    func insert(_ value: T) {
        
        _ = syncQueue.sync(flags: .barrier) {
            set.insert(value)
        }
    }
}
