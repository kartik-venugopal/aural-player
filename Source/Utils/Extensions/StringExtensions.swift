import Foundation

extension String {
    
    func lowerCasedAndTrimmed() -> String {self.lowercased().trim()}
    
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
