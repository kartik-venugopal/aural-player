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
    
    func nonEmptyStringValue(forKey key: Key) -> String? {
        
        if let string = self[key, String.self] {
            return string.isEmptyAfterTrimming ? nil : string
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
    
    subscript<T>(_ key: String, type: T.Type) -> T? where T: Any {
        
        get {self[key] as? T}
        set {}
    }
    
    func cgFloatValue(forKey key: String) -> CGFloat? {
        
        if let number = self[key, NSNumber.self] {
            return CGFloat(number.floatValue)
        }
        
        return nil
    }
    
    func nonEmptyStringValue(forKey key: String) -> String? {
        
        if let string = self[key, String.self] {
            return string.isEmptyAfterTrimming ? nil : string
        }
        
        return nil
    }
    
    func enumValue<T: RawRepresentable>(forKey key: String, ofType: T.Type) -> T? where T.RawValue == String {
        
        if let string = self[key, String.self] {
            return T(rawValue: string)
        }
        
        return nil
    }
    
    func urlValue(forKey key: String) -> URL? {
        
        if let string = self[key, String.self] {
            return URL(fileURLWithPath: string)
        }
        
        return nil
    }
    
    func urlArrayValue(forKey key: String) -> [URL]? {
        self[key, [String].self]?.map {URL(fileURLWithPath: $0)}
    }
    
    func dateValue(forKey key: String) -> Date? {
        
        if let string = self[key, String.self] {
            return Date.fromString(string)
        }
        
        return nil
    }
    
    func nsPointValue(forKey key: String) -> NSPoint? {
        
        if let dict = self[key, NSDictionary.self],
           let px = dict.cgFloatValue(forKey: "x"),
           let py = dict.cgFloatValue(forKey: "y") {
            
            return NSPoint(x: px, y: py)
        }
        
        return nil
    }
    
    func nsSizeValue(forKey key: String) -> NSSize? {
        
        if let dict = self[key, NSDictionary.self],
           let width = dict.cgFloatValue(forKey: "width"),
           let height = dict.cgFloatValue(forKey: "height") {
            
            return NSSize(width: width, height: height)
        }
        
        return nil
    }
    
    func nsRectValue(forKey key: String) -> NSRect? {
        
        if let dict = self[key, NSDictionary.self],
           let origin = dict.nsPointValue(forKey: "origin"),
           let size = dict.nsSizeValue(forKey: "size") {
            
            return NSRect(origin: origin, size: size)
        }
        
        return nil
    }
}
