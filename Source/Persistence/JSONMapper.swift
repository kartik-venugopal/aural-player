//
//  JSONMapper.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Uses Swift reflection to serialize object values into an NSDictionary for serialization as JSON.
///
class JSONMapper {
    
    private static let nullValue: NSNull = NSNull()
    
    static func map(_ obj: Any) -> NSDictionary {
        return mapObject(obj, usingMirror: Mirror(reflecting: obj))
    }
    
    private static func mapObject(_ obj: Any, usingMirror mirror: Mirror) -> NSDictionary {
        
        var dict: [NSString: AnyObject] = [:]
        
        for child in mirror.allChildren {
            
            if let childName: String = child.label {
                dict[childName as NSString] = mapChild(child)
            }
        }
        
        return dict as NSDictionary
    }
    
    private static func mapChild(_ child: Mirror.Child) -> AnyObject {
        
        let unwrapResult = unwrapOptional(child.value)
        
        if let unwrappedValue = unwrapResult.value {
            
            // Value is not optional or optional value is non-nil.
            return mapAny(unwrappedValue, usingMirror: unwrapResult.mirror)
            
        } else {
            
            // Optional value is nil
            return nullValue
        }
    }
    
    private static func unwrapOptional(_ optionalValue: Any) -> (value: Any?, mirror: Mirror) {
        
        let mirror = Mirror(reflecting: optionalValue)
        
        if mirror.displayStyle == .optional {
            
            let mirrorChildren = mirror.allChildren
            
            if mirrorChildren.isEmpty {
                return (nil, mirror)
                
            } else {
                
                // Value is non-nil, need to recompute the mirror for the unwrapped value.
                let value = mirrorChildren.first!.value
                return (value, Mirror(reflecting: value))
            }
        }
        
        return (optionalValue, mirror)
    }
    
    private static func mapAny(_ value: Any, usingMirror mirror: Mirror) -> AnyObject {
        
        // Primitive (no children)
        if let mappedValue = tryToMapAsPrimitive(value, usingMirror: mirror) {
            return mappedValue
        }
        
        switch mirror.displayStyle {
        
        case .class, .struct, .tuple:       return mapObject(value, usingMirror: mirror)
            
        case .enum:                         return String(describing: value) as NSString
            
        case .collection:                   return mapArray(value, usingMirror: mirror)
            
        case .dictionary:                   return mapDictionary(value)
            
        default:                            return String(describing: value) as NSString

        }
    }
    
    private static func tryToMapAsPrimitive(_ obj: Any, usingMirror mirror: Mirror) -> AnyObject? {
        
        // Number
        if !(obj is Bool), let number = obj as? NSNumber {
            return number
        }
        
        // String
        if let string = obj as? String {
            return string as NSString
        }
        
        // URL
        if let url = obj as? URL {
            return url.path as NSString
        }
        
        // Date
        if let date = obj as? Date {
            return date.serializableString() as NSString
        }
        
        // Boolean
        if let boolObj = obj as? Bool {
            return boolObj as AnyObject
        }
        
        return nil
    }
    
    private static func mapArray(_ obj: Any, usingMirror mirror: Mirror) -> NSArray {
        
        let array: [AnyObject] = mirror.allChildren.map {mapChild($0)}
        return NSArray(array: array)
    }
    
    private static func mapDictionary(_ obj: Any) -> NSDictionary {
        
        var dict: [NSString: AnyObject] = [:]
        
        if let nsDict = obj as? NSDictionary {
            
            for (key, value) in nsDict {
                dict[String(describing: key) as NSString] = mapAny(value, usingMirror: Mirror(reflecting: value))
            }
        }

        return dict as NSDictionary
    }
}
