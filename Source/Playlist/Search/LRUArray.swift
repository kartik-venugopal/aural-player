//
//  LRUArray.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// An array-based ordered data structure that maintains items in chronological order
/// and does not allow duplicates.
///
/// If an item is added a second time, it will be removed from its previous location and
/// re-inserted at the top of the array (i.e. the location of the most recent item).
///
class LRUArray<T: Equatable> {
    
    var array: [T] = []
    
    // Adds a single new element to the array. If the array is already filled to capacity, the least recently added item will be removed to make room for the new element.
    func add(_ newElement: T) {
        
        // If the item already exists in array, remove it from the previous location (so it may be added at the top).
        _ = array.removeItem(newElement)
        
        // Add the new element at the end
        array.append(newElement)
    }
    
    // Removes a single element from the array, if it exists.
    func remove(_ element: T) {
        _ = array.removeItem(element)
    }
 
    // Returns a copy of the underlying array, maintaining the order of its elements
//    func toArray() -> [T] {
//
//        let arrayCopy = array
//        return arrayCopy
//    }
    
    var first: T? {
        array.first
    }
    
    var last: T? {
        array.last
    }
    
    func reversed() -> [T] {
        array.reversed()
    }
 
    // Checks if the array contains a particular element.
    func contains(_ element: T) -> Bool {
        array.contains(element)
    }
    
    func clear() {
        array.removeAll()
    }
}
