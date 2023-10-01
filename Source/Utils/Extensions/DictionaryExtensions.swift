//
//  DictionaryExtensions.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension Dictionary {

    subscript<T: Any>(_ key: Key, type: T.Type) -> T? {

        get {self[key] as? T}
        set {}
    }

    func numberValue(forKey key: Key) -> NSNumber? {
        self[key, NSNumber.self]
    }

    func numberArrayValue(forKey key: Key) -> [NSNumber]? {
        self[key, [NSNumber].self]
    }

    func intValue(forKey key: Key) -> Int? {
        numberValue(forKey: key)?.intValue
    }

    func uintValue(forKey key: Key) -> UInt? {
        numberValue(forKey: key)?.uintValue
    }

    func uint32Value(forKey key: Key) -> UInt32? {
        numberValue(forKey: key)?.uint32Value
    }

    func uint64Value(forKey key: Key) -> UInt64? {
        numberValue(forKey: key)?.uint64Value
    }

    func floatValue(forKey key: Key) -> Float? {
        numberValue(forKey: key)?.floatValue
    }

    func doubleValue(forKey key: Key) -> Double? {
        numberValue(forKey: key)?.doubleValue
    }

    func nonEmptyStringValue(forKey key: Key) -> String? {

        if let string = self[key, String.self] {
            return string.isEmptyAfterTrimming ? nil : string
        }

        return nil
    }

    func cgFloatValue(forKey key: Key) -> CGFloat? {

        if let number = self[key, NSNumber.self] {
            return CGFloat(number.floatValue)
        }

        return nil
    }

    func enumValue<T: RawRepresentable>(forKey key: Key, ofType: T.Type) -> T? where T.RawValue == String {

        if let string = self[key, String.self] {
            return T(rawValue: string)
        }

        return nil
    }

    func urlValue(forKey key: Key) -> URL? {

        if let string = self[key, String.self] {
            return URL(fileURLWithPath: string)
        }

        return nil
    }
}

extension NSDictionary {
    
    subscript<T: Any>(_ key: Key, type: T.Type) -> T? {

        get {self[key] as? T}
        set {}
    }
    
    func numberValue(forKey key: Key) -> NSNumber? {
        self[key, NSNumber.self]
    }
    
    func numberArrayValue(forKey key: Key) -> [NSNumber]? {
        self[key, [NSNumber].self]
    }
    
    func intValue(forKey key: Key) -> Int? {
        numberValue(forKey: key)?.intValue
    }
    
    func uintValue(forKey key: Key) -> UInt? {
        numberValue(forKey: key)?.uintValue
    }
    
    func uint32Value(forKey key: Key) -> UInt32? {
        numberValue(forKey: key)?.uint32Value
    }
    
    func uint64Value(forKey key: Key) -> UInt64? {
        numberValue(forKey: key)?.uint64Value
    }
    
    func floatValue(forKey key: Key) -> Float? {
        numberValue(forKey: key)?.floatValue
    }
    
    func doubleValue(forKey key: Key) -> Double? {
        numberValue(forKey: key)?.doubleValue
    }
    
    func nonEmptyStringValue(forKey key: Key) -> String? {
        
        if let string = self[key, String.self] {
            return string.isEmptyAfterTrimming ? nil : string
        }
        
        return nil
    }
    
    func cgFloatValue(forKey key: Key) -> CGFloat? {
        
        if let number = self[key, NSNumber.self] {
            return CGFloat(number.floatValue)
        }
        
        return nil
    }
}
