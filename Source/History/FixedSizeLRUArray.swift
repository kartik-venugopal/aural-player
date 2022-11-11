//
//  FixedSizeLRUArray.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// A fixed-size array-based data structure that maintains the most recent n items, where n is the size
/// of the array.
///
/// This is useful, for instance, when keeping track of a fixed-size set of items in chronological order.
///
class FixedSizeLRUArray<T: Equatable>: LRUArray<T> {
    
    private var size: Int
    
    var count: Int {size}
    
    init(size: Int) {
        self.size = size
    }
    
    // Adds a single new element to the array. If the array is already filled to capacity, the least recently added item will be removed to make room for the new element.
    override func add(_ newElement: T) {
        
        super.add(newElement)
        
        // Max size has been reached, remove the oldest item
        if array.count > size {
            array.removeFirst()
        }
    }
    
    func resize(_ newSize: Int) {
        
        if newSize != self.size {
            self.size = newSize
        }
        
        if newSize < array.count {
            
            // Shrink the array (remove the n oldest items where n = the difference between current array size and the new maximum array size).
            array.removeFirst(array.count - newSize)
        }
    }
}
