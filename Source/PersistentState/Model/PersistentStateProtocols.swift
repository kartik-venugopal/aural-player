import Foundation

// Marks an object as having state that needs to be persisted
protocol PersistentModelObject {
    
    associatedtype T: PersistentStateProtocol
    
    // Retrieves persistent state for this model object
    var persistentState: T {get}
}

// Marks an object as being suitable for persistence, i.e. it is serializable/deserializable
protocol PersistentStateProtocol {
    
    init?(_ map: NSDictionary)
}

// Marks an object as being suitable for persistence, i.e. it is serializable/deserializable
protocol PersistentStateFactoryProtocol {
    
    associatedtype T: PersistentStateProtocol
    
    static func deserialize(_ map: NSDictionary) -> T?
}
