//
//  TrackKeyedMap.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A special type of **Dictionary** in which a track is mapped
/// to an arbitrary object.
///
/// - Parameter T:      The type of the values in the map.
///
class TrackKeyedMap<T: Any> {

    var map: [URL: T] = [:]
    
    subscript(_ key: URL) -> T? {
        
        get {map[key]}
        
        set {
            
            if let theValue = newValue {
                map[key] = theValue
                
            } else {
                map.removeValue(forKey: key)
            }
        }
    }
    
    subscript(_ key: Track) -> T? {
        
        get {map[key.file]}
        
        set {
            
            if let theValue = newValue {
                map[key.file] = theValue
                
            } else {
                map.removeValue(forKey: key.file)
            }
        }
    }
    
    func hasFor(_ track: Track) -> Bool {
        map[track.file] != nil
    }
    
    func removeFor(_ track: Track) {
        map[track.file] = nil
    }
    
    func removeAll() {
        map.removeAll()
    }
    
    func all() -> [T] {
        [T](map.values)
    }
    
    var size: Int {map.count}
}
