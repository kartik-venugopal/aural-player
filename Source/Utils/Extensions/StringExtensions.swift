//
//  StringExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension String {
    
    func truncate(font: NSFont, maxWidth: CGFloat) -> String {
        
        let selfWidth = size(withFont: font).width
        
        if selfWidth <= maxWidth {
            return self
        }
        
        let len = self.count
        var cur = len - 2
        var str: String = ""
        
        while cur >= 0 {
            
            str = self.substring(range: 0..<(cur + 1)) + "..."
            
            let strWidth = str.size(withFont: font).width
            if strWidth <= maxWidth {
                return str
            }
            
            cur -= 1
        }
        
        return str
    }
    
    func size(withFont font: NSFont) -> CGSize {
        size(withAttributes: [.font: font])
    }
    
    // For a given piece of text rendered in a certain font, and a given line width, calculates the number of lines the text will occupy (e.g. in a multi-line label)
    func numberOfLines(font: NSFont, lineWidth: CGFloat) -> Int {
        
        let size: CGSize = self.size(withAttributes: [.font: font])
        return Int(ceil(size.width / lineWidth))
    }
    
    func withEncodingAndNullsRemoved() -> String {
        (self.removingPercentEncoding ?? self).replacingOccurrences(of: "\0", with: "")
    }
    
    // Splits a camel cased word into separate words, all capitalized. For ex, "albumName" -> "Album Name". This is useful for display within the UI.
    func splitAsCamelCaseWord(capitalizeEachWord: Bool) -> String {
        
        var newString: String = ""
        
        var firstLetter: Bool = true
        for eachCharacter in self {
            
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
    func camelCased() -> String {
        
        var newString: String = ""
        var wordStart: Bool = false
        
        for eachCharacter in self {
            
            // Ignore spaces
            if eachCharacter == " " {
                
                wordStart = true
                continue
            }
            
            if newString == "" {
                
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
    
    
    func lowerCasedAndTrimmed() -> String {self.lowercased().trim()}
    
    // Checks if the string 1 - is non-null, 2 - has characters, 3 - not all characters are whitespace
    static func isEmpty(_ string: String?) -> Bool {
        string == nil ? true : string!.isEmptyAfterTrimming
    }
    
    var isEmptyAfterTrimming: Bool {
        trim().isEmpty
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + (self.count > 1 ? self.substring(range: 1..<self.count) : "")
    }

    subscript (index: Int) -> Character {
        
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }
    
    func substring(range: Range<Int>) -> String {
        
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return String(self[startIndex..<stopIndex])
    }
    
    var isAcronym: Bool {
        !self.contains(where: {$0.isLowercase})
    }
    
    func alphaNumericMatch(to other: String) -> Bool {
        
        if self == other {return true}
        
        if count != other.count {return false}
        
        var characterMatch: Bool = false
        
        for index in 0..<count {
            
            let myChar = self[index]
            let otherChar = other[index]
            
            if myChar.isAlphaNumeric && otherChar.isAlphaNumeric {
                
                if myChar != otherChar {
                    return false
                } else {
                    characterMatch = true
                }
            }
        }
        
        return characterMatch
    }
    
    // The lower the number, the better the match. 0 means perfect match.
    func similarityToString(other: String) -> Int {
        
        if self == other {return 0}
        
        let myLen = self.count
        let otherLen = other.count
        let matchLen = min(myLen, otherLen)
        
        var score: Int = 0
        
        for index in 0..<matchLen {
            
            if self[index] != other[index] {
                score.increment()
            }
        }
        
        if myLen != otherLen {
            score += abs(myLen - otherLen)
        }
        
        return score
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func encodedAsURLComponent() -> String {
        self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self.replacingOccurrences(of: " ", with: "%20")
    }
}

extension Character {
    
    var isAlphaNumeric: Bool {self.isLetter || self.isNumber}
}

extension Substring.SubSequence {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
