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
    
    func removeAll() {
        map.removeAll()
    }
}
