//
//  CompositeKeyMap.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A special type of **Dictionary** in which each mapping is accessed through
/// two keys instead of one, i.e. each key is a composite key consisting of two parts.
///
/// - Parameter T:      The type of both keys that constitute the composite key.
///
/// - Parameter U:      The type of the values mapped to the keys.
///
/// Example (storing cover art images mapped to a track's artist / album):
///
/// ```
///     var keyMap = CompositeKeyMap<String, NSImage>()
///     keyMap["Conjure One", "Exilarch"] = myCoverArtImage
/// ```
///
class CompositeKeyMap<T: Hashable, U: Any> {
    
    private var map: [T: [T: U]] = [:]
    
    var count: Int {
        map.count
    }
    
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
