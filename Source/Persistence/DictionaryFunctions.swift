import Foundation

extension NSDictionary {
    
    func persistentObjectValue<T: PersistentStateProtocol>(forKey key: String, ofType type: T.Type) -> T? {
        
        if let dict = self[key, NSDictionary.self] {
            return T.init(dict)
        }
        
        return nil
    }
    
    func persistentFactoryObjectValue<T: PersistentStateFactoryProtocol, U: PersistentStateProtocol>(forKey key: String, ofType type: T.Type) -> U? {
        
        if let dict = self[key, NSDictionary.self] {
            return T.deserialize(dict) as? U
        }
        
        return nil
    }
    
    func persistentObjectArrayValue<T: PersistentStateProtocol>(forKey key: String, ofType type: T.Type) -> [T]? {
        
        if let array = self[key, [NSDictionary].self] {
            return array.compactMap {T.init($0)}
        }
        
        return nil
    }
    
    func persistentColorValue(forKey key: String) -> ColorPersistentState? {
        
        if let dict = self[key, NSDictionary.self] {
            return ColorPersistentState.deserialize(dict)
        }
        
        return nil
    }
}
