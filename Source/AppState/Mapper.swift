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
    
    private static func mapAny(_ value: Any) -> AnyObject {
        
        // Primitive (no children)
        if isPrimitive(value) {
            return mapPrimitive(value)
        }
        
        let mirror = mirrorFor(value)
        
        // Array
        if mirror.displayStyle == .collection {
            return mapArray(value)
        }
        
        // Dictionary
        if mirror.displayStyle == .dictionary {
            return mapDictionary(value)
        }
        
        // Class/struct type or Tuple
        if !mirror.allChildren().isEmpty || mirror.displayStyle == .tuple {
            return mapObject(value, [])
        }
        
        // Default to primitive mapping
        return mapPrimitive(value)
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
            dict[mapToString(key) as NSString] = mapAny(value)
        }
        
        return dict as NSDictionary
    }
    
    private static func isPrimitive(_ obj: Any) -> Bool {
        
        return obj is Float || obj is CGFloat || obj is Int || obj is UInt64 || obj is Int64 || obj is Int32 || obj is OSType || obj is UInt32 || obj is Double || obj is Bool || obj is String || obj is URL || obj is Date || mirrorFor(obj).displayStyle == .enum
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
        if obj is Float || obj is CGFloat || obj is Int || obj is UInt64 || obj is Int64 || obj is Int32 || obj is OSType || obj is UInt32 || obj is Double {
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

extension NSDictionary {
    
    func intValue(forKey key: String) -> Int? {
        (self[key] as? NSNumber)?.intValue
    }
    
    func uint32Value(forKey key: String) -> UInt32? {
        (self[key] as? NSNumber)?.uint32Value
    }
    
    func uint64Value(forKey key: String) -> UInt64? {
        (self[key] as? NSNumber)?.uint64Value
    }
    
    func floatValue(forKey key: String) -> Float? {
        (self[key] as? NSNumber)?.floatValue
    }
    
    func floatArray(forKey key: String) -> [Float]? {
        
        if let array = self[key] as? [NSNumber] {
            return array.compactMap {$0.floatValue}
        }
        
        return nil
    }
    
    func cgFloatValue(forKey key: String) -> CGFloat? {
        
        if let floatValue = (self[key] as? NSNumber)?.floatValue {
            return CGFloat(floatValue)
        }
        
        return nil
    }
    
    func doubleValue(forKey key: String) -> Double? {
        (self[key] as? NSNumber)?.doubleValue
    }
    
    func stringValue(forKey key: String) -> String? {
        self[key] as? String
    }
    
    func nonEmptyStringValue(forKey key: String) -> String? {
        
        if let string = self[key] as? String {
            return string.isEmptyAfterTrimming ? nil : string
        }
        
        return nil
    }
    
    func boolValue(forKey key: String) -> Bool? {
        self[key] as? Bool
    }
    
    func objectValue<T: PersistentStateProtocol>(forKey key: String, ofType: T.Type) -> T? {
        
        if let dict = self[key] as? NSDictionary {
            return T.init(dict)
        }
        
        return nil
    }
    
    func factoryObjectValue<T: PersistentStateFactoryProtocol, U: PersistentStateProtocol>(forKey key: String, ofType: T.Type) -> U? {
        
        if let dict = self[key] as? NSDictionary {
            return T.deserialize(dict) as? U
        }
        
        return nil
    }
    
    func arrayValue<T: PersistentStateProtocol>(forKey key: String, ofType: T.Type) -> [T]? {
        
        if let array = self[key] as? [NSDictionary] {
            return array.compactMap {T.init($0)}
        }
        
        return nil
    }
    
    func enumValue<T: RawRepresentable>(forKey key: String, ofType: T.Type) -> T? where T.RawValue == String {
        
        if let string = self[key] as? String {
            return T(rawValue: string)
        }
        
        return nil
    }
    
    func urlValue(forKey key: String) -> URL? {
        
        if let string = self[key] as? String {
            return URL(fileURLWithPath: string)
        }
        
        return nil
    }
    
    func urlArrayValue(forKey key: String) -> [URL]? {
        (self[key] as? [String])?.map {URL(fileURLWithPath: $0)}
    }
    
    func dateValue(forKey key: String) -> Date? {
        
        if let string = self[key] as? String {
            return Date.fromString(string)
        }
        
        return nil
    }
    
    func nsPointValue(forKey key: String) -> NSPoint? {
        
        if let dict = self[key] as? NSDictionary,
           let px = dict.cgFloatValue(forKey: "x"),
           let py = dict.cgFloatValue(forKey: "y") {
            
            return NSPoint(x: px, y: py)
        }
        
        return nil
    }
    
    func nsSizeValue(forKey key: String) -> NSSize? {
        
        if let dict = self[key] as? NSDictionary,
           let width = dict.cgFloatValue(forKey: "width"),
           let height = dict.cgFloatValue(forKey: "height") {
            
            return NSSize(width: width, height: height)
        }
        
        return nil
    }
    
    func nsRectValue(forKey key: String) -> NSRect? {
        
        if let dict = self[key] as? NSDictionary,
           let origin = dict.nsPointValue(forKey: "origin"),
           let size = dict.nsSizeValue(forKey: "size") {
            
            return NSRect(origin: origin, size: size)
        }
        
        return nil
    }
}
