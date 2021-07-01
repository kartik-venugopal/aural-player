//
//  DictionaryExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension Dictionary {

    subscript<T>(_ key: Key, type: T.Type) -> T? where T: Any {

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

    func floatArrayValue(forKey key: Key) -> [Float]? {
        numberArrayValue(forKey: key)?.map {$0.floatValue}
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
    
    subscript<T>(_ key: Key, type: T.Type) -> T? where T: Any {

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
    
    func floatArrayValue(forKey key: Key) -> [Float]? {
        numberArrayValue(forKey: key)?.map {$0.floatValue}
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
    
    func urlArrayValue(forKey key: Key) -> [URL]? {
        self[key, [String].self]?.map {URL(fileURLWithPath: $0)}
    }
    
    func dateValue(forKey key: Key) -> Date? {
        
        if let string = self[key, String.self] {
            return Date.fromString(string)
        }
        
        return nil
    }
    
    func nsPointValue(forKey key: Key) -> NSPoint? {
        
        if let dict = self[key, NSDictionary.self],
           let px = dict.cgFloatValue(forKey: "x"),
           let py = dict.cgFloatValue(forKey: "y") {
            
            return NSPoint(x: px, y: py)
        }
        
        return nil
    }
    
    func nsSizeValue(forKey key: Key) -> NSSize? {
        
        if let dict = self[key, NSDictionary.self],
           let width = dict.cgFloatValue(forKey: "width"),
           let height = dict.cgFloatValue(forKey: "height") {
            
            return NSSize(width: width, height: height)
        }
        
        return nil
    }
    
    func nsRectValue(forKey key: Key) -> NSRect? {
        
        if let dict = self[key, NSDictionary.self],
           let origin = dict.nsPointValue(forKey: "origin"),
           let size = dict.nsSizeValue(forKey: "size") {
            
            return NSRect(origin: origin, size: size)
        }
        
        return nil
    }
}
