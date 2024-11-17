//
//  KVOTokens.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class KVOTokens<Object: NSObject, Property> {
    
    private var tokens: [NSKeyValueObservation] = []
    
    private var observedProperties: Set<KeyPath<Object, Property>> = Set()
    
    func addObserver(forObject object: Object, keyPath: KeyPath<Object, Property>,
                     options: NSKeyValueObservingOptions = [.initial, .new],
                     changeHandler: @escaping (Object, Property) -> Void) {
        
        tokens.append(object.observe(keyPath, options: options) {_, changedValue in
            
            if let newValue = changedValue.newValue {
                changeHandler(object, newValue)
            }
        })
        
        observedProperties.insert(keyPath)
    }
    
    func isPropertyObserved(_ property: KeyPath<Object, Property>) -> Bool {
        observedProperties.contains(property)
    }
    
    func invalidate() {
        
        tokens.forEach {$0.invalidate()}
        tokens.removeAll()
        
        observedProperties.removeAll()
    }
}
