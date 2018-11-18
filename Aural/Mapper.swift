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
            
            let val = mapPrimitive(child.value)
//            print(child.label, "(Primitive)", val)
            return val
        }
        
        let childMirror = mirrorFor(child.value)
        
        // Array
        if childMirror.displayStyle == .collection {
            let val = mapArray(child.value)
//            print(child.label, "(Array)", val)
            return val
        }
        
        // Dictionary
        if childMirror.displayStyle == .dictionary {
            let val = mapDictionary(child.value)
//            print(child.label, "(Dict)", val)
            return val
        }
        
        // Class/struct type or Tuple
        if !childMirror.allChildren().isEmpty || childMirror.displayStyle == .tuple {
            let val = mapObject(child.value, [])
//            print(child.label, "(Object or Tuple)", val)
            return val
        }
        
//        print(child.label, "Defaulting to primitive")
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
            dict[String(describing: key) as NSString] = mapPrimitive(value)
        }
        
        return dict as NSDictionary
    }
    
    private static func isPrimitive(_ obj: Any) -> Bool {
        
        return obj is Float || obj is CGFloat || obj is Int || obj is Double || obj is Bool || obj is String || obj is URL || obj is Date || mirrorFor(obj).displayStyle == .enum
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
