/*
    A collection of assorted utility functions for reusability.
*/

import Cocoa

class Utils {
    
    // Time values in seconds
    static let oneMin = 60
    static let oneHour = 60 * oneMin
    
    // Formats a duration (time interval) from seconds to a displayable string showing hours, minutes, and seconds. For example, 500 seconds becomes "8:20", and 3675 seconds becomes "1:01:15"
    static func formatDuration(_ _duration: Double) -> String {
        
        let duration = Int(round(_duration))
        
        let secs = duration % oneMin
        let mins = (duration / oneMin) % oneMin
        let hrs = duration / oneHour
        
        return hrs > 0 ? String(format: "%d:%02d:%02d", hrs, mins, secs) : String(format: "%d:%02d", mins, secs)
    }
    
    // Formats a duration (time interval) from seconds to a displayable string showing minutes, and seconds. For example, 500 seconds becomes "8 min 20 sec", 120 seconds becomes "2 min", and 36 seconds becomes "36 sec"
    static func formatDuration_minSec(_ duration: Int) -> String {
        
        let secs = duration % oneMin
        let mins = duration / oneMin
        
        return mins > 0 ? (secs > 0 ? String(format: "%d min %d sec", mins, secs) : String(format: "%d min", mins)) : String(format: "%d sec", secs)
    }
    
    // Splits a camel cased word into separate words, all capitalized. For ex, "albumName" -> "Album Name". This is useful for display within the UI.
    static func splitCamelCaseWord(_ word: String) -> String {
        
        var newString: String = ""
        
        for eachCharacter in word.characters {
            if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
                newString.append(" ")
            }
            newString.append(eachCharacter)
        }
        
        return newString.capitalized
    }
    
    // Provides a comma separated String representation of an integer, that is easy to read. For ex, 15700900 -> "15,700,900"
    static func readableLongInteger(_ num: Int64) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.characters.count - 1
        
        var c = 0
        for eachCharacter in numString.characters {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.append(",")
            }
            c += 1
        }
        
        return readableNumString
    }
    
    // Checks if the string 1 - is non-null, 2 - has characters, 3 - not all characters are whitespace
    static func isStringEmpty(_ string: String?) -> Bool {
        
        if (string == nil) {
            return true
        }
        
        return trimString(string!).isEmpty
    }
    
    // Trims all whitespace from a string and returns the result
    static func trimString(_ string: String) -> String {
        
        return string.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
}
