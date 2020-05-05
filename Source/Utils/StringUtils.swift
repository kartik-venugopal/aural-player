/*
    A collection of assorted String utility functions.
*/

import Cocoa

class StringUtils {
    
    // Time values in seconds
    static let oneMin = 60
    static let oneHour = 60 * oneMin
    
    // Given the elapsed time, in seconds, for a playing track, and its duration (also in seconds), returns 2 formatted strings: 1 - Formatted elapsed time, and 2 - Formatted time remaining. See formatSecondsToHMS()
    static func formatTrackTimes(_ elapsedSeconds: Double, _ duration: Double, _ percentageElapsed: Double, _ timeElapsedDisplayType: TimeElapsedDisplayType = .formatted, _ timeRemainingDisplayType: TimeRemainingDisplayType = .formatted) -> (elapsed: String, remaining: String) {
        
        let elapsedSecondsInt = Int(round(elapsedSeconds))
        
        var elapsedString: String
        var remainingString: String
        
         switch timeElapsedDisplayType {
         
         case .formatted:
         
         elapsedString = formatSecondsToHMS(elapsedSeconds)
         
         case .seconds:
         
         let secStr = StringUtils.commaSeparatedInt(elapsedSecondsInt)
         elapsedString = String(format: "%@ sec", secStr)
         
         case .percentage:
         
         elapsedString = String(format: "%d%%", Int(round(percentageElapsed)))
            
         }
         
         switch timeRemainingDisplayType {
         
         case .formatted:
         
         remainingString = formatSecondsToHMS(duration - Double(elapsedSecondsInt), true)
         
         case .seconds:
         
         let secStr = StringUtils.commaSeparatedInt(Int(round(duration - Double(elapsedSecondsInt))))
         remainingString = String(format: "- %@ sec", secStr)
         
         case .percentage:
         
         let percentageRemaining = 100 - percentageElapsed
         remainingString = String(format: "- %d%%", Int(round(percentageRemaining)))
         
         case .duration_formatted:
         
         remainingString = StringUtils.formatSecondsToHMS(duration)
         
         case .duration_seconds:
         
         let secStr = StringUtils.commaSeparatedInt(Int(round(duration)))
         remainingString = String(format: "%@ sec", secStr)
            
         }
         
        return (elapsedString, remainingString)
    }
    
    /* Formats a duration (time interval) from seconds to a displayable string showing hours, minutes, and seconds. For example, 500 seconds becomes "8:20", and 3675 seconds becomes "1:01:15".
     
        The "includeMinusPrefix" indicates whether or not to include a prefix of "-" in the formatted string returned.
    */
    static func formatSecondsToHMS(_ _timeSeconds: Double, _ includeMinusPrefix: Bool = false) -> String {
        
        let timeSeconds = Int(round(_timeSeconds))
        
        let secs = timeSeconds % oneMin
        let mins = (timeSeconds / oneMin) % oneMin
        let hrs = timeSeconds / oneHour
        
        return hrs > 0 ? String(format: "%@%d:%02d:%02d", includeMinusPrefix ? "- " : "", hrs, mins, secs) : String(format: "%@%d:%02d", includeMinusPrefix ? "- " : "", mins, secs)
    }
    
    // Formats a duration (time interval) from seconds to a displayable string showing minutes, and seconds. For example, 500 seconds becomes "8 min 20 sec", 120 seconds becomes "2 min", and 36 seconds becomes "36 sec"
    static func formatSecondsToHMS_minSec(_ duration: Int) -> String {
        
        let secs = duration % oneMin
        let mins = duration / oneMin
        
        return mins > 0 ? (secs > 0 ? String(format: "%d min %d sec", mins, secs) : String(format: "%d min", mins)) : String(format: "%d sec", secs)
    }
    
    // Formats a duration (time interval) from seconds to a displayable string showing minutes, and seconds. For example, 500 seconds becomes "8 min 20 sec", 120 seconds becomes "2 min", and 36 seconds becomes "36 sec"
    static func formatSecondsToHMS_hrMinSec(_ duration: Int) -> String {
        
        let hrs = duration / oneHour
        let mins = (duration - (hrs * oneHour)) / oneMin
        let secs = duration % oneMin
        
        var hrsStr = ""
        
        if hrs > 0 {
            hrsStr = String(format: "%d hr ", hrs)
        }
        
        var secsStr = "0 sec"
        
        if secs > 0 {
            secsStr = String(format: "%d sec", secs)
        } else {
            secsStr = ""
        }
        
        var minsStr = ""
        
        if mins > 0 {
            minsStr = String(format: "%d min ", mins)
        } else {
            minsStr = hrs > 0 ? (secs > 0 ?  "0 min " : "") : ""
        }
        
        let fStr = String(format: "%@%@%@", hrsStr, minsStr, secsStr)
        
        return fStr
    }
    
    // Splits a camel cased word into separate words, all capitalized. For ex, "albumName" -> "Album Name". This is useful for display within the UI.
    static func splitCamelCaseWord(_ word: String, _ capitalizeEachWord: Bool) -> String {
        
        var newString: String = ""
        
        var firstLetter: Bool = true
        for eachCharacter in word {
            
            if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
                
                // Upper case character
                
                // Add a space to delimit the words
                if (!firstLetter) {
                    // Don't append a space if it's the first word (if first word is already capitalized as in "AlbumName")
                    newString.append(" ")
                } else {
                    firstLetter = false
                }
                
                if (capitalizeEachWord) {
                    newString.append(eachCharacter)
                } else {
                    newString.append(String(eachCharacter).lowercased())
                }
                
            } else if (firstLetter) {
                
                // Always capitalize the first word
                newString.append(String(eachCharacter).capitalized)
                firstLetter = false
                
            } else {
                
                newString.append(eachCharacter)
            }
        }
        
        return newString
    }
    
    // Joins multiple words into one camel-cased word. For example, "Medium hall" -> "mediumHall"
    static func camelCase(_ words: String) -> String {
        
        var newString: String = ""
        
        var wordStart: Bool = false
        for eachCharacter in words {
            
            // Ignore spaces
            if (eachCharacter == " ") {
                wordStart = true
                continue
            }
            
            if (newString == "") {
                
                // The very first character needs to be lowercased
                newString.append(String(eachCharacter).lowercased())
                
            } else if (wordStart) {
                
                // The first character of subsequent words needs to be capitalized
                newString.append(String(eachCharacter).capitalized)
                wordStart = false
                
            } else {
                
                newString.append(eachCharacter)
            }
        }
        
        return newString
    }
    
    // Provides a comma separated String representation of an integer, that is easy to read. For ex, 15700900 -> "15,700,900"
    static func readableLongInteger(_ num: Int64) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.count - 1
        
        var c = 0
        for eachCharacter in numString {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.append(",")
            }
            c += 1
        }
        
        return readableNumString
    }
    
    static func commaSeparatedInt(_ num: Int) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.count - 1
        
        var c = 0
        for eachCharacter in numString {
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
        
        return string!.trim().isEmpty
    }
    
    static func cleanUpString(_ string: String) -> String {
        
        var cleanStr = string.removingPercentEncoding ?? string
        cleanStr = cleanStr.replacingOccurrences(of: "\0", with: "")    // Remove null characters
        return cleanStr
    }
    
    // For a given piece of text rendered in a certain font, and a given line width, calculates the number of lines the text will occupy (e.g. in a multi-line label) 
    static func numberOfLines(_ text: String, _ font: NSFont, _ lineWidth: CGFloat) -> Int {
        
        let size: CGSize = text.size(withAttributes: [NSAttributedString.Key.font: font])
        
        return Int(ceil(size.width / lineWidth))
    }
    
    static func sizeOfString(_ text: String, _ font: NSFont) -> CGSize {
        return text.size(withAttributes: [NSAttributedString.Key.font: font])
    }
    
    static func widthOfString(_ text: String, _ font: NSFont) -> CGFloat {
        return text.size(withAttributes: [NSAttributedString.Key.font: font]).width
    }
    
    static func truncate(_ text: String, _ font: NSFont, _ maxWidth: CGFloat) -> String {
        
        if widthOfString(text, font) <= maxWidth {
            return text
        }
        
        let len = text.count
        var cur = len - 2
        var str: String = ""
        
        while cur >= 0 {
            
            str = text.substring(range: 0..<(cur + 1)) + "..."
            
            if widthOfString(str, font) <= maxWidth {
                return str
            }
            
            cur -= 1
        }
        
        return str
    }
}

extension String {
    
    subscript (index: Int) -> Character {
        
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }
    
    func substring(range: Range<Int>) -> String {
        
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return String(self[startIndex..<stopIndex])
    }
    
}
