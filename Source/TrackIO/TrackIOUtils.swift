import AVFoundation

extension AVAssetTrack {
    
    var formatDescription: CMFormatDescription {
        self.formatDescriptions.first as! CMFormatDescription
    }
    
    var format: FourCharCode {
        CMFormatDescriptionGetMediaSubType(formatDescription)
    }
    
    var format4CharString: String {
        format.toString()
    }
}

extension FourCharCode {
    
    // Create a String representation of a FourCC
    func toString() -> String {
        
        let bytes: [CChar] = [
            CChar((self >> 24) & 0xff),
            CChar((self >> 16) & 0xff),
            CChar((self >> 8) & 0xff),
            CChar(self & 0xff),
            0
        ]
        let result = String(cString: bytes)
        let characterSet = CharacterSet.whitespaces
        return result.trimmingCharacters(in: characterSet)
    }
}

infix operator <> : DefaultPrecedence
extension AudioFormatFlags {
    
    static func <> (left: AudioFormatFlags, right: AudioFormatFlags) -> Bool {
        (left & right) != 0
    }
}

// Unused code
//extension AudioStreamBasicDescription {
//
//    var pcmFormatDescription: String {
//
//        var formatStr: String = "PCM "
//
//        let bitDepth: UInt32 = mBitsPerChannel
//        let isFloat: Bool = mFormatFlags <> kAudioFormatFlagIsFloat
//        let isSignedInt: Bool = mFormatFlags <> kAudioFormatFlagIsSignedInteger
//        let isBigEndian: Bool = mFormatFlags <> kAudioFormatFlagIsBigEndian
//
//        formatStr += isFloat ? "\(bitDepth)-bit float " : (isSignedInt ? "signed \(bitDepth)-bit " : "unsigned \(bitDepth)-bit ")
//
//        formatStr += isBigEndian ? "(big-endian)" : "(little-endian)"
//
//        return formatStr
//    }
//}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue
    }
    
    var keyAsString: String? {
        
        if let key = self.key as? String {
            return key
        }
        
        if let id = self.identifier {
            
            // This is required for .iTunes keyspace items ("itsk").
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                
                let key = (tokens[1].replacingOccurrences(of: "%A9", with: "@").trim())
                return key.removingPercentEncoding ?? key
            }
        }
        
        return nil
    }
    
    var valueAsString: String? {

        if !StringUtils.isStringEmpty(self.stringValue) {
            return self.stringValue
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue {
            return String(data: data, encoding: .utf8)
        }
        
        if let date = self.dateValue {
            return String(describing: date)
        }
        
        return nil
    }
    
    var valueAsNumericalString: String {
        
        if !StringUtils.isStringEmpty(self.stringValue), let num = Int(self.stringValue!) {
            return String(describing: num)
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue, let num = Int(data.hexEncodedString(), radix: 16) {
            return String(describing: num)
        }
        
        return "0"
    }
}

extension Array {
    
    func firstNonNilMappedValue<R>(_ mapFunc: (Element) -> R?) ->R? {

        for elm in self {

            if let result = mapFunc(elm) {
                return result
            }
        }

        return nil
    }
}
