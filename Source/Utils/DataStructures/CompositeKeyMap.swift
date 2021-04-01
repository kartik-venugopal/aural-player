import Foundation

class CompositeKeyMap<T: Hashable, U: Any> {
    
    private var map: [T: [T: U]] = [:]
    
    subscript(_ key1: T, _ key2: T) -> U? {
        
        get {map[key1]?[key2]}
        
        set {
            
            if let theValue = newValue {
            
                if map[key1] == nil {
                    map[key1] = [:]
                }
                
                map[key1]?[key2] = theValue
                
            } else {
                map[key1]?.removeValue(forKey: key2)
            }
        }
    }
    
    var entries: [(T, T, U)] {
        
        var arr: [(T, T, U)] = []
        
        for (key1, key1Map) in map {
            
            for (key2, value) in key1Map {
                arr.append((key1, key2, value))
            }
        }
        
        return arr
    }
    
    func removeValue(for key1: T, and key2: T) -> U? {
        return map[key1]?.removeValue(forKey: key2)
    }
    
    func removeAll() {
        map.removeAll()
    }
}

class ConcurrentCompositeKeyMap<T: Hashable, U: Any> {
    
    private var map: CompositeKeyMap<T, U> = CompositeKeyMap()
    private let lock = DispatchSemaphore(value: 1)
    
    subscript(_ key1: T, _ key2: T) -> U? {
        
        get {
            
            lock.wait()
            defer { lock.signal() }
            
            return map[key1, key2]
        }
        
        set {
            
            lock.wait()
            defer { lock.signal() }
            
            map[key1, key2] = newValue
        }
    }
    
    var entries: [(T, T, U)] {
        
        lock.wait()
        defer { lock.signal() }
        
        return map.entries
    }
    
    func removeAll() {
        
        lock.wait()
        defer { lock.signal() }
        
        map.removeAll()
    }
}
