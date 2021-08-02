//
//  MappedObjects.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A contract for a generic user-managed object (eg. preset / playlist) that can be mapped to a key.
///
protocol UserManagedObject: MenuItemMappable {
    
    var key: String {get set}
    
    var userDefined: Bool {get}
}

///
/// A utility to perform CRUD operations on an ordered / mapped collection
/// of **MappedObject** objects.
///
/// - SeeAlso: `MappedObject`
///
class UserManagedObjects<P: UserManagedObject> {
    
    private let userDefinedObjectsMap: UserManagedObjectsMap<P> = UserManagedObjectsMap()
    private let systemDefinedObjectsMap: UserManagedObjectsMap<P> = UserManagedObjectsMap()
    
    var userDefinedObjects: [P] {userDefinedObjectsMap.allObjects}
    var systemDefinedObjects: [P] {systemDefinedObjectsMap.allObjects}
    
    var defaultPreset: P? {nil}
    
    init(systemDefinedObjects: [P], userDefinedObjects: [P]) {
        
        systemDefinedObjects.forEach {
            self.systemDefinedObjectsMap.addObject($0)
        }
        
        userDefinedObjects.forEach {
            self.userDefinedObjectsMap.addObject($0)
        }
    }
    
    func addObject(_ object: P) {
        userDefinedObjectsMap.addObject(object)
    }
    
    func object(named name: String) -> P? {
        systemDefinedObjectsMap[name] ?? userDefinedObjectsMap[name]
    }

    var numberOfUserDefinedObjects: Int {userDefinedObjectsMap.count}
    
    func userDefinedObject(named name: String) -> P? {
        userDefinedObjectsMap[name]
    }
    
    func systemDefinedObject(named name: String) -> P? {
        systemDefinedObjectsMap[name]
    }
    
    func deleteObject(atIndex index: Int) -> P {
        return userDefinedObjectsMap.removeObjectAtIndex(index)
    }
    
    func deleteObjects(atIndices indices: IndexSet) -> [P] {
        
        return indices.sortedDescending().map {
            userDefinedObjectsMap.removeObjectAtIndex($0)
        }
    }
    
    func deleteObject(named name: String) -> P? {
        return userDefinedObjectsMap.removeObject(withKey: name)
    }
    
    func deleteObjects(named objectNames: [String]) -> [P] {
        
        return objectNames.compactMap {
            deleteObject(named: $0)
        }
    }
    
    func renameObject(named oldName: String, to newName: String) {
        userDefinedObjectsMap.reMap(objectWithKey: oldName, toKey: newName)
    }
    
    func objectExists(named name: String) -> Bool {
        userDefinedObjectsMap.objectWithKeyExists(name) || systemDefinedObjectsMap.objectWithKeyExists(name)
    }
    
    func userDefinedObjectExists(named name: String) -> Bool {
        userDefinedObjectsMap.objectWithKeyExists(name)
    }
}

///
/// A specialized collection that functions as both an array and dictionary for **UserManagedObject** objects
/// so that the objects can be accessed efficiently both by index and key.
///
fileprivate class UserManagedObjectsMap<P: UserManagedObject> {
    
    private var array: [P] = []
    private var map: [String: P] = [:]
    
    subscript(_ index: Int) -> P {
        array[index]
    }
    
    subscript(_ key: String) -> P? {
        map[key]
    }
    
    func addObject(_ object: P) {
        
        array.append(object)
        map[object.key] = object
    }
    
    func removeObject(withKey key: String) -> P? {
        
        guard let index = array.firstIndex(where: {$0.key == key}) else {return nil}
        
        map.removeValue(forKey: key)
        return array.remove(at: index)
    }
    
    func reMap(objectWithKey oldKey: String, toKey newKey: String) {
        
        if var object = map[oldKey] {

            // Modify the key within the object
            object.key = newKey
            
            // Re-map the object to the new key
            map.removeValue(forKey: oldKey)
            map[newKey] = object
        }
    }
    
    func removeObjectAtIndex(_ index: Int) -> P {
        
        let object = array[index]
        map.removeValue(forKey: object.key)
        return array.remove(at: index)
    }
    
    func objectWithKeyExists(_ key: String) -> Bool {
        map[key] != nil
    }
    
    var count: Int {array.count}
    
    var allObjects: [P] {array}
}
