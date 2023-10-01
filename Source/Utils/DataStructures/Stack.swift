//
//  Stack.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Data structure that provides LIFO operations - push / pop / peek.
///
/// Backed by an array.
///
class Stack<T: Any> {
 
    // Backing array
    private var array: [T] = []
    
    func push(_ elm: T) {
        array.append(elm)
    }
    
    func pop() -> T? {
        return array.popLast()
    }
    
    func peek() -> T? {
        return array.last
    }
    
    func clear() {
        array.removeAll()
    }
    
    var size: Int {array.count}
    
    var isEmpty: Bool {array.isEmpty}
}
