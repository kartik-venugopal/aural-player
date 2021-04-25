import Foundation

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
    
    func colorValue(forKey key: String) -> ColorPersistentState? {
        
        if let dict = self[key] as? NSDictionary {
            return ColorPersistentState.deserialize(dict)
        }
        
        return nil
    }
}
