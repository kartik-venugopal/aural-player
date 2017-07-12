/*
    A collection of assorted utility functions for reusability.
*/

import Cocoa

class Utils {
    
    // Time values in seconds
    static let oneMin = 60
    static let oneHour = 60 * oneMin
    
    // Formats a duration (time interval) from seconds to a displayable string showing hours, minutes, and seconds. For example, 500 seconds becomes "8:20", and 3675 seconds becomes "1:01:15"
    static func formatDuration(duration: Double) -> String {
        return formatDuration(Int(round(duration)))
    }
    
    static func formatDuration(var duration: Int) -> String {
        
        let hrs = duration / oneHour
        duration -= hrs * oneHour
        
        let mins = duration / oneMin
        duration -= mins * oneMin
        
        let secs = duration
        
        var durStr = ""
        
        if (hrs > 0) {
            durStr += String(hrs) + ":"
        }
        
        if (mins > 0) {
            
            if (hrs > 0) {
                durStr += String(format: "%02d:", mins)
            } else {
                durStr += String(mins) + ":"
            }
            
        } else {
            // 0 minutes
            
            if (hrs == 0) {
                durStr += "0:"
            } else {
                durStr += "00:"
            }
        }
        
        durStr += String(format: "%02d", secs)
        
        return durStr
    }
    
    // Splits a camel cased word into separate words, all capitalized. For ex, "albumName" -> "Album Name". This is useful for display within the UI.
    static func splitCamelCaseWord(word: String) -> String {
        
        var newString: String = ""
        
        for eachCharacter in word.characters {
            if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
                newString.appendContentsOf(" ")
            }
            newString.append(eachCharacter)
        }
        
        return newString.capitalizedString
    }
    
    // Provides a comma separated String representation of an integer, that is easy to read. For ex, 15700900 -> "15,700,900"
    static func readableLongInteger(num: Int64) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.characters.count - 1
        
        var c = 0
        for eachCharacter in numString.characters {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.appendContentsOf(",")
            }
            c++
        }
        
        return readableNumString
    }
    
    // Checks if the string 1 - is non-null, 2 - has characters, 3 - not all characters are whitespace
    static func isStringEmpty(string: String?) -> Bool {
        
        if (string == nil) {
            return true
        }
        
        return trimString(string!).isEmpty
    }
    
    // Trims all whitespace from a string and returns the result
    static func trimString(string: String) -> String {
        
        return string.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
    }
    
    static func isDirectory(url: NSURL) -> Bool {
        
        var isDirectory: ObjCBool = ObjCBool(false)
        NSFileManager.defaultManager().fileExistsAtPath(url.path!, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
}