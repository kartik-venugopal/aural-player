import Foundation

extension UserDefaults {
    
    subscript(_ key: String) -> Any? {
        
        get {self.object(forKey: key)}
        set {self.setValue(newValue, forKey: key)}
    }
}
