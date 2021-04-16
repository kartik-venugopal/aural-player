import Foundation

class Theme: StringKeyedItem {
    
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    let fontScheme: FontScheme
    let colorScheme: ColorScheme
    let windowAppearance: WindowAppearance
    
    init(name: String, fontScheme: FontScheme, colorScheme: ColorScheme, windowAppearance: WindowAppearance) {
        
        self.name = name
        self.fontScheme = fontScheme
        self.colorScheme = colorScheme
        self.windowAppearance = windowAppearance
    }
}
