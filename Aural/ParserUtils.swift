import AVFoundation

class ParserUtils {
    
    static func getID3Genre(_ item: AVMetadataItem, _ offset: Int = 0) -> String? {
        
        if let num = item.numberValue {
            return GenreMap.forID3Code(num.intValue + offset)
        }
        
        if let str = item.stringValue {
            return parseID3GenreNumericString(str, offset)
        }
        
        if let data = item.dataValue {
            
            if let dataType = item.dataType, dataType as NSString == kCMMetadataBaseDataType_RawData as NSString {
                
                let vals = data.filter({num -> Bool in num > 0})
                
                if let firstVal = vals.first {
                    return GenreMap.forID3Code(Int(firstVal) + offset)
                }
                
            } else if let dataType = item.dataType, dataType as NSString == kCMMetadataBaseDataType_UTF8 as NSString {
                
                return String(data: data, encoding: .utf8)
                
            } else {
                
                let vals = data.filter({num -> Bool in num > 0})
                
                if vals.count > 1 {
                    // Probably a string
                    return String(data: data, encoding: .utf8)
                    
                } else if vals.count == 1, let firstVal = vals.first {

                    return GenreMap.forID3Code(Int(firstVal) + offset)
                }
            }
        }
        
        return nil
    }
    
    static func parseID3GenreNumericString(_ string: String, _ offset: Int = 0) -> String {
        
        if let genreCode = parseNumericString(string) {
            // Look up genreId in ID3 table
            return GenreMap.forID3Code(genreCode + offset) ?? string
        }
        
        return string
    }
    
    static func parseNumericString(_ string: String) -> Int? {
        
        let decimalChars = CharacterSet.decimalDigits
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let number = Int(numberStr) {
                return number
            }
        }
        
        return nil
    }
    
    static func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let number = item.numberValue {
            return (number.intValue, nil)
        }
        
        if let stringValue = item.stringValue?.trim() {
            
            // Parse string (e.g. "2 / 13")
            
           return parseDiscOrTrackNumberString(stringValue)

        } else if let dataValue = item.dataValue {
            
            let vals = dataValue.filter({num -> Bool in num > 0})
            
            switch vals.count {
                
            case 0: return (nil, nil)
                
            case 1: return (Int(vals[0]), nil)
                
            default: return (Int(vals[0]), Int(vals[1]))
                
            }
        }
        
        return nil
    }
    
    static func parseDiscOrTrackNumberString(_ stringValue: String) -> (number: Int?, total: Int?)? {
        
        // Parse string (e.g. "2 / 13")
        
        if let num = Int(stringValue) {
            return (num, nil)
        }
        
        let tokens = stringValue.split(separator: "/")
        
        switch tokens.count {
            
        case 0: return (nil, nil)
            
        case 1: return (Int(tokens[0].trim()), nil)
            
        default:    return (Int(tokens[0].trim()), Int(tokens[1].trim()))
            
        }
    }
    
    static func getImageMetadata(_ image: NSData) -> NSDictionary? {
        
        if let imageSourceRef = CGImageSourceCreateWithData(image, nil), let currentProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) {
        
            return NSMutableDictionary(dictionary: currentProperties)
        }
        
        return nil
    }
}
