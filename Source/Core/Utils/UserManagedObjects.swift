//
//  MappedObjects.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import OrderedCollections

///
/// A contract for a generic user-managed object (eg. preset / playlist) that can be mapped to a key.
///
protocol UserManagedObject: MenuItemMappable {
    
    var key: String {get set}
    
    var userDefined: Bool {get}
}

protocol PresetsManagerProtocol {
    
    associatedtype Object: UserManagedObject
    
    var numberOfUserDefinedObjects: Int {get}
    
    func objectExists(named name: String) -> Bool
    
    var userDefinedObjects: [Object] {get}
    
    func renameObject(named oldName: String, to newName: String)
    
    @discardableResult func deleteObjects(atIndices indices: IndexSet) -> [Object]
}

///
/// A utility to perform CRUD operations on an ordered / mapped collection
/// of **UserManagedObject** objects.
///
/// - SeeAlso: `UserManagedObject`
///
class UserManagedObjects<O: UserManagedObject>: PresetsManagerProtocol {
    
    typealias Object = O

    var userDefinedObjectsMap: OrderedDictionary<String, O> = OrderedDictionary()
    var systemDefinedObjectsMap: OrderedDictionary<String, O> = OrderedDictionary()
    
    var userDefinedObjects: [O] {Array(userDefinedObjectsMap.values)}
    var systemDefinedObjects: [O] {Array(systemDefinedObjectsMap.values)}
    
    var defaultPreset: O? {nil}
    
    init(systemDefinedObjects: [O], userDefinedObjects: [O]) {
        
        systemDefinedObjects.forEach {
            self.systemDefinedObjectsMap[$0.key] = $0
        }
        
        userDefinedObjects.forEach {
            self.userDefinedObjectsMap[$0.key] = $0
        }
    }
    
    func addObject(_ object: O) {
        userDefinedObjectsMap[object.key] = object
    }
    
    func object(named name: String) -> O? {
        systemDefinedObjectsMap[name] ?? userDefinedObjectsMap[name]
    }
    
    var numberOfSystemDefinedObjects: Int {systemDefinedObjectsMap.count}
    var numberOfUserDefinedObjects: Int {userDefinedObjectsMap.count}
    var totalNumberOfObjects: Int {systemDefinedObjectsMap.count + userDefinedObjectsMap.count}
    
    func userDefinedObject(named name: String) -> O? {
        userDefinedObjectsMap[name]
    }
    
    func indexOfUserDefinedObject(named name: String) -> Int? {
        userDefinedObjectsMap.index(forKey: name)
    }
    
    func systemDefinedObject(named name: String) -> O? {
        systemDefinedObjectsMap[name]
    }
    
    @discardableResult func deleteObject(atIndex index: Int) -> O {
        return userDefinedObjectsMap.remove(at: index).value
    }
    
    @discardableResult func deleteObjects(atIndices indices: IndexSet) -> [O] {
        
        return indices.sortedDescending().map {
            userDefinedObjectsMap.remove(at: $0).value
        }
    }
    
    @discardableResult func deleteObject(named name: String) -> O? {
        return userDefinedObjectsMap.removeValue(forKey: name)
    }
    
    @discardableResult func deleteObjects(named objectNames: [String]) -> [O] {
        
        return objectNames.compactMap {
            deleteObject(named: $0)
        }
    }
    
    func renameObject(named oldName: String, to newName: String) {
        
        if var object = userDefinedObjectsMap.removeValue(forKey: oldName) {
            
            object.key = newName
            userDefinedObjectsMap[newName] = object
        }
    }
    
    func objectExists(named name: String) -> Bool {
        userDefinedObjectsMap[name] != nil || systemDefinedObjectsMap[name] != nil
    }
    
    func userDefinedObjectExists(named name: String) -> Bool {
        userDefinedObjectsMap[name] != nil
    }
    
    func sortUserDefinedObjects(by sortFunction: (O, O) -> Bool) {
        userDefinedObjectsMap.sort(by: {(key1AndObject1, key2AndObject2) in sortFunction(key1AndObject1.1, key2AndObject2.1)})
    }
    
    func updateObjects(matchingPredicate predicate: (O) -> Bool, updateFunction: (O) -> Void) {
        
        for object in userDefinedObjectsMap.values {
            
            if predicate(object) {
                updateFunction(object)
            }
        }
    }
}
