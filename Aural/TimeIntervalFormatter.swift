import Cocoa

class JumpToTimeSecondsFormatter: Formatter {

    var maxValue: Int = Int.max
    
    // Used to get the stepper value
    var valueFunction: (() -> String)?
    
    // Used to set the stepper value
    var updateFunction: ((Int) -> Void)?
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {
            
            if updateFunction != nil {
                updateFunction!(0)
            }
            
            return true
        }
        
        if !isNumeric(partialString) {
            return false
        }
        
        if let num = Int(partialString) {
            
            if num <= maxValue && updateFunction != nil {
                updateFunction!(num)
            }
            
            return num <= maxValue
            
        } else {
            
            return false
        }
    }
    
    private func isNumeric(_ string: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    override func string(for obj: Any?) -> String? {
        return valueFunction != nil ? valueFunction!() : "0"
    }
    
    override func editingString(for obj: Any) -> String? {
        
        return valueFunction != nil ? valueFunction!() : "0"
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        return true
    }
}

//extension String {
//    public func index(of char: Character) -> Int? {
//        if let idx = characters.index(of: char) {
//            return characters.distance(from: startIndex, to: idx)
//        }
//        return nil
//    }
//}
