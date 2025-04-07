//
// UserPreference.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

@propertyWrapper
class UserPreference<Value> {
    
    let key: String
    let defaultValue: Value
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        
        get {
            userDefaults.object(forKey: key) as? Value ?? defaultValue
        }
        
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct OptionalUserPreference<Value> {
    
    let key: String
    
    var wrappedValue: Value? {
        
        get {
            userDefaults.object(forKey: key) as? Value
        }
        
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
class EnumUserPreference<Value: RawRepresentable>: UserPreference<Value> {
    
    override var wrappedValue: Value {
        
        get {
            
            if let rawValue = userDefaults.object(forKey: key) as? Value.RawValue {
                return Value(rawValue: rawValue) ?? defaultValue
            }
            
            return defaultValue
        }
        
        set {
            userDefaults.set(newValue.rawValue, forKey: key)
        }
    }
}

@propertyWrapper
struct URLUserPreference {
    
    let key: String
    
    var wrappedValue: URL? {
        
        get {
            
            if let path = userDefaults.string(forKey: key) {
                return URL(fileURLWithPath: path)
            }
            
            return nil
        }
        
        set {
            userDefaults.set(newValue?.path, forKey: key)
        }
    }
}
