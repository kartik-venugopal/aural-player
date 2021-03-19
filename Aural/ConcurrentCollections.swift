import Foundation

class ConcurrentMap<T:Hashable, U:Any> {
    
    private let syncQueue: DispatchQueue
    private var map: [T: U] = [:]
    
    init(_ id: String) {
        syncQueue = DispatchQueue(label: id, attributes: .concurrent)
    }
    
    func kvPairs() -> [T: U] {
        let copy = map
        return copy
    }
    
    func hasForKey(_ key: T) -> Bool {
        var hasValue: Bool = false
        syncQueue.sync(flags: .barrier) {
            if map[key] != nil {
                hasValue = true
            }
        }
        return hasValue
    }
    
    func getForKey(_ key: T) -> U? {
        var value: U? = nil
        syncQueue.sync(flags: .barrier) {
            if let v = map[key] {
                value = v
            }
        }
        return value
    }
    
    func put(key: T, value: U) {
        syncQueue.sync(flags: .barrier) {
            map[key] = value
        }
    }
    
    func remove(key: T) {
        _ = syncQueue.sync(flags: .barrier) {
            map.removeValue(forKey: key)
        }
    }
}

class ConcurrentSet<T: Hashable> {
    
    private let syncQueue: DispatchQueue
    private var set: Set<T> = Set<T>()
    
    init(_ id: String) {
        syncQueue = DispatchQueue(label: id, attributes: .concurrent)
    }
    
    func contains(_ value: T) -> Bool {
        
        var hasValue: Bool = false
        
        syncQueue.sync(flags: .barrier) {
            
            if set.contains(value) {
                hasValue = true
            }
        }
        
        return hasValue
    }
    
    func insert(_ value: T) {
        
        _ = syncQueue.sync(flags: .barrier) {
            set.insert(value)
        }
    }
}
