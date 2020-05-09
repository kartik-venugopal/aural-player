/*
    A collection of assorted String utility functions.
*/

import Cocoa

class StringUtils {
    
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
