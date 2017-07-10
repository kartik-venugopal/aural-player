/*
    Utility class for convenient String construction through concatenation.
*/

import Foundation

class StringBuilder {
    
    private var string: String = ""
    
    func append(string: String) {
        self.string += string
    }
    
    func appendKeyValue(key: String, value: String) {
        self.string += key
        self.string += " = "
        self.string += value
        self.string += "\n"
    }
    
    func appendLine(string: String) {
        append(string + "\n")
    }
    
    func build() -> String {
        return string
    }
    
    func clear() {
        string = ""
    }
}