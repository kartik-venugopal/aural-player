import Foundation

class JSONMapper {
    
    static func map(_ obj: Any, _ ignoreProps: [String] = []) -> NSDictionary {
        return mapObject(obj, ignoreProps)
    }
    
    static func mapToArray(_ obj: Any) -> NSArray {
        return mapArray(obj)
    }
    
    private static func mapChild(_ child: Mirror.Child) -> AnyObject {
        
        // Primitive (no children)
        if isPrimitive(child.value) {
            return mapPrimitive(child.value)
        }
        
        let childMirror = mirrorFor(child.value)
        
        // Array
        if childMirror.displayStyle == .collection {
            return mapArray(child.value)
        }
        
        // Dictionary
        if childMirror.displayStyle == .dictionary {
            return mapDictionary(child.value)
        }
        
        // Class/struct type or Tuple
        if !childMirror.allChildren().isEmpty || childMirror.displayStyle == .tuple {
            return mapObject(child.value, [])
        }
        
        // Default to primitive mapping
        return mapPrimitive(child.value)
    }
    
    private static func mapObject(_ obj: Any, _ ignoreProps: [String] = []) -> NSDictionary {
        
        let unwrapped = unwrapOptional(obj)
        if unwrapped.isNil {return [:] as NSDictionary}
        
        let obj: Any = unwrapped.value!
        
        var dict: [NSString: AnyObject] = [:]
        let objMirror = mirrorFor(obj)
        
        for child in objMirror.allChildren() {
            
            if let childName = child.label, childName.hasPrefix("_transient_") || ignoreProps.contains(childName) {continue}
            dict[(child.label ?? "") as NSString] = mapChild(child)
        }
        
        return dict as NSDictionary
    }
    
    private static func mapArray(_ obj: Any) -> NSArray {
        
        let unwrapped = unwrapOptional(obj)
        if unwrapped.isNil {return [] as NSArray}
        
        let obj: Any = unwrapped.value!
        var array: [AnyObject] = []
        let mir = mirrorFor(obj)
        
        for child in mir.allChildren() {
            array.append(mapChild(child))
        }
        
        return NSArray(array: array)
    }
    
    private static func mapDictionary(_ obj: Any) -> NSDictionary {
        
        let unwrapped = unwrapOptional(obj)
        if unwrapped.isNil {return [:] as NSDictionary}
        
        let obj: Any = unwrapped.value!
        
        var dict: [NSString: AnyObject] = [:]
        for (key, value) in obj as! NSDictionary {
            // Assume primitive values
            dict[mapToString(key) as NSString] = mapPrimitive(value)
        }
        
        return dict as NSDictionary
    }
    
    private static func isPrimitive(_ obj: Any) -> Bool {
        
        return obj is Float || obj is CGFloat || obj is Int || obj is Double || obj is Bool || obj is String || obj is URL || obj is Date || mirrorFor(obj).displayStyle == .enum
    }
    
    private static func mapToString(_ obj: Any) -> String {
        
        if let url = obj as? URL {
            return url.path
        }
        
        return String(describing: obj)
    }
    
    private static func mapPrimitive(_ obj: Any) -> AnyObject {
        
        let unwrapped = unwrapOptional(obj)
        if unwrapped.isNil {return NSNull()}
        
        let obj: Any = unwrapped.value!
        
        // Number
        if obj is Float || obj is CGFloat || obj is Int || obj is Double {
            return obj as! NSNumber
        }
        
        // Boolean
        if let bool_obj = obj as? Bool {
            return bool_obj as AnyObject
        }
        
        // Enum
        if mirrorFor(obj).displayStyle == .enum {
            return String(describing: obj) as NSString
        }
        
        // URL
        if let url = obj as? URL {
            return url.path as NSString
        }
        
        // Date
        if let date = obj as? Date {
            return date.serializableString() as NSString
        }
        
        return String(describing: obj) as AnyObject
    }
}

extension Mirror {
    
    func allChildren() -> [Mirror.Child] {
        
        var children: [Mirror.Child] = []
        children.append(contentsOf: self.children)
        
        if let superMirror = self.superclassMirror {
            children.append(contentsOf: superMirror.allChildren())
        }
        
        return children
    }
}

func mirrorFor(_ obj: Any) -> Mirror {
    return Mirror(reflecting: obj)
}

func unwrapOptional(_ obj: Any) -> (isNil: Bool, value: Any?) {
    
    let mir = mirrorFor(obj)
    
    if mir.displayStyle == .optional {
        
        if mir.allChildren().isEmpty {return (true, nil)}
        
        return (false, mir.allChildren()[0].value)
    }
    
    return (false, obj)
}

func mapEnum<T: RawRepresentable>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T where T.RawValue == String {
    if let rawVal = map[key] as? String, let enumVal = T.self.init(rawValue: rawVal) {return enumVal} else {return defaultValue}
}

func mapDirectly<T: Any>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T {
    if let value = map[key] as? T {return value} else {return defaultValue}
}

func mapDirectly<T: Any>(_ map: NSDictionary, _ key: String) -> T? {
    if let value = map[key] as? T {return value} else {return nil}
}

func mapNumeric<T: Any>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T {
    
    if let value = map[key] as? NSNumber {
        return doMapNumeric(value, T.self)
    }
    
    return defaultValue
}

fileprivate func doMapNumeric<T: Any>(_ value: NSNumber, _ type: T.Type) -> T {
    
    switch String(describing: type) {
        
    case "Float", "CGFloat": return value.floatValue as! T
        
    case "Double": return value.doubleValue as! T
        
    case "Int": return value.intValue as! T
        
    // Should not happen
    default: return value.doubleValue as! T
        
    }
}

// Allows optional values
func mapNumeric<T: Any>(_ map: NSDictionary, _ key: String) -> T? {
    
    if let value = map[key] as? NSNumber {
        return doMapNumeric(value, T.self)
    }
    
    return nil
}

func mapNSPoint(_ map: NSDictionary) -> NSPoint? {
    
    if let px = map["x"] as? NSNumber, let py = map["y"] as? NSNumber {
        return NSPoint(x: CGFloat(px.floatValue), y: CGFloat(py.floatValue))
    }
    
    return nil
}

func mapNSSize(_ map: NSDictionary) -> NSSize? {
    
    if let wd = map["width"] as? NSNumber, let ht = map["height"] as? NSNumber {
        return NSSize(width: CGFloat(wd.floatValue), height: CGFloat(ht.floatValue))
    }
    
    return nil
}
