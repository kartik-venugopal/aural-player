/*
    Utility class for convenient String construction through concatenation.
*/

import Foundation

class StringBuilder {
    
    fileprivate var string: String = ""
    
    func append(_ string: String) {
        self.string += string
    }
    
    func appendKeyValue(_ key: String, value: String) {
        self.string += key
        self.string += " = "
        self.string += value
        self.string += "\n"
    }
    
    func appendLine(_ string: String) {
        append(string + "\n")
    }
    
    func build() -> String {
        return string
    }
    
    func clear() {
        string = ""
    }
}
