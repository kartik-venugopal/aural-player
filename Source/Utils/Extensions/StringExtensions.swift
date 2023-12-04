//
//  StringExtensions.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

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
    
    ///
    /// For a given font, computes the width of the widest numerical character.
    ///
    static func widthOfWidestNumber(forFont font: NSFont) -> CGFloat {
        
        var maxWidth: CGFloat = 0
        
        for number in 0...9 {
            
            let numString = String(number)
            let width = numString.size(withFont: font).width
            
            if width > maxWidth {
                maxWidth = width
            }
        }
        
        return maxWidth
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
    
    ///
    /// Returns a 2-D array, one array for each match. Within each such array, each element is a capture group within the match.
    ///
    func match(regex: String) -> [[String]] {
        
        let nsString = self as NSString
        
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
    
    func encodedAsURLComponent() -> String {
        self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self.replacingOccurrences(of: " ", with: "%20")
    }
    
    func draw(in rect: NSRect, withFont font: NSFont, andColor color: NSColor) {
        self.draw(in: rect, withAttributes: [.font: font, .foregroundColor: color])
    }
    
    func draw(in rect: NSRect, withFont font: NSFont, andColor color: NSColor, style: NSParagraphStyle?) {
        
        if let theStyle = style {
            self.draw(in: rect, withAttributes: [.font: font, .foregroundColor: color, .paragraphStyle: theStyle])
        } else {
            self.draw(in: rect, withAttributes: [.font: font, .foregroundColor: color])
        }
    }
    
    // Draws text, centered, within an NSRect, with a certain font and color
    func drawCentered(in rect: NSRect, withFont font: NSFont, andColor color: NSColor, yOffset: CGFloat = 0, style: NSParagraphStyle? = nil) {
        
        // Compute size and origin
        let size: CGSize = self.size(withFont: font)
        let sx = (rect.width - size.width) / 2
        let sy = (rect.height - size.height) / 2 - 1
        
        self.draw(in: NSRect(x: sx, y: sy + yOffset, width: size.width, height: size.height),
                  withFont: font,
                  andColor: color,
                  style: style)
    }
    
    /*
        Takes a formatted artist/album string like "Artist -- Album" and truncates it so that it fits horizontally within a text view.
     */
    static func truncateCompositeString(_ font: NSFont, _ maxWidth: CGFloat, _ fullLengthString: String,
                                        _ s1: String, _ s2: String, _ separator: String) -> String {
        
        // Check if the full length string fits. If so, no need to truncate.
        let origWidth = fullLengthString.size(withFont: font).width
        
        if origWidth <= maxWidth {
            return fullLengthString
        }
        
        // If fullLengthString doesn't fit, find out which is longer ... s1 or s2 ... truncate the longer one just enough to fit
        let w1 = s1.size(withFont: font).width
        let w2 = s2.size(withFont: font).width
        
        if w1 > w2 {
            
            // Reconstruct the composite string with the truncated s1
            
            let wRemainder1: CGFloat = origWidth - w1
            
            // Width available for s1 = maximum width - (original width - s1's width)
            let max1: CGFloat = maxWidth - wRemainder1
            
            let t1 = s1.truncate(font: font, maxWidth: max1)
            return String(format: "%@%@%@", t1, separator, s2)
            
        } else {
            
            // s2 is longer than s1, simply truncate the string as a whole
            return fullLengthString.truncate(font: font, maxWidth: maxWidth)
        }
    }
    
    func utf8EncodedString()-> String {
        
        let messageData = self.data(using: .nonLossyASCII)
        return String(data: messageData!, encoding: .utf8) ?? ""
    }
    
    func MD5() -> Data {
        
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

    func MD5Hex() -> String {
        MD5().map { String(format: "%02hhx", $0) }.joined()
    }
    
    func encodedAsURLQueryParameter() -> String {
        self.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .queryParmCharacters) ?? self.replacingOccurrences(of: " ", with: "+")
    }
}

extension Character {
    
    var isAlphaNumeric: Bool {self.isLetter || self.isNumber}
}

extension CharacterSet {
    
    static let queryParmCharacters: CharacterSet = .alphanumerics.union(CharacterSet.init(charactersIn: "+"))
}

extension Substring.SubSequence {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension NSParagraphStyle {
    
    static let centeredText: NSMutableParagraphStyle = {
       
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        return textStyle
    }()
}

extension NSMutableParagraphStyle {
    
    convenience init(lineSpacing: CGFloat) {

        self.init()
        self.lineSpacing = lineSpacing
    }
}
