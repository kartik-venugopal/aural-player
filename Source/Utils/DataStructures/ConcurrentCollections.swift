//
//  ConcurrentCollections.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class ConcurrentMap<T: Hashable, U: Any> {
 
    private let lock = DispatchSemaphore(value: 1)
    private var map: [T: U] = [:]
    
    var kvPairs: [T: U] {
        
        lock.wait()
        defer { lock.signal() }
        
        let copy = map
        return copy
    }
    
    var keys: [T] {
        
        lock.wait()
        defer { lock.signal() }
        
        return Array(map.keys)
    }
    
    var values: [U] {
        
        lock.wait()
        defer { lock.signal() }
        
        return Array(map.values)
    }
    
    subscript(_ key: T) -> U? {
        
        get {
            
            lock.wait()
            defer { lock.signal() }
            
            return map[key]
        }
        
        set (newValue) {
            
            lock.wait()
            defer { lock.signal() }
            
            if let theValue = newValue {
                
                // newValue is non-nil
                map[key] = theValue
                
            } else {
                
                // newValue is nil, implying that any existing value should be removed for this key.
                _ = map.removeValue(forKey: key)
            }
        }
    }
    
    func hasForKey(_ key: T) -> Bool {
        
        lock.wait()
        defer { lock.signal() }
        
        return map[key] != nil
    }
    
    func remove(_ key: T) -> U? {
        
        lock.wait()
        defer { lock.signal() }
        
        return map.removeValue(forKey: key)
    }
    
    func removeAll() {
        
        lock.wait()
        defer { lock.signal() }
        
        map.removeAll()
    }
}

class ConcurrentSet<T: Hashable> {
    
    private let lock = DispatchSemaphore(value: 1)
    private(set) var set: Set<T> = Set<T>()
    
    func contains(_ value: T) -> Bool {
        
        lock.wait()
        defer { lock.signal() }
        
        return set.contains(value)
    }
    
    func insert(_ value: T) {
        
        lock.wait()
        defer { lock.signal() }
        
        set.insert(value)
    }
}

//class ConcurrentArray<T> {
//
//    private var array: [T] = []
//    private let lock = DispatchSemaphore(value: 1)
//
//    func append(_ elm: T) {
//
//        lock.wait()
//        defer { lock.signal() }
//
//        array.append(elm)
//    }
//
//    func removeAll() {
//
//        lock.wait()
//        defer { lock.signal() }
//
//        array.removeAll()
//    }
//
//    var elements: [T] {array}
//}
