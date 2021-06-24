//
//  Queue.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// FIFO
class Queue<T> {
    
    private var array: [T] = []
    
    func enqueue(_ item: T) {
        array.append(item)
    }
    
    func dequeue() -> T? {
        
        if array.count > 0 {
            return array.remove(at: 0)
        }
        
        return nil
    }
    
    func dequeueAll() -> [T] {
        
        let copy = array
        array.removeAll()
        return copy
    }
    
    func peek() -> T? {array.first}
    
    func clear() {
        array.removeAll()
    }
    
    func size() -> Int {
        return array.count
    }
    
    var isEmpty: Bool {array.isEmpty}
    
    func toArray() -> [T] {
        let copy = array
        return copy
    }
}
