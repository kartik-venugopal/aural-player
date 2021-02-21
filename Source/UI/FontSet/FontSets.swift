import Cocoa

class FontSets {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultFontSet: FontSet = FontSet("_default_", FontSetPreset.standard)
    
    // The current system color scheme. It is initialized with the default scheme.
    static var systemFontSet: FontSet = defaultFontSet
    
    static func initialize() {
        _ = systemFontSet
    }
    
    static func applyFontSet(named name: String) -> FontSet? {
        
        if let fontSetPreset = FontSetPreset.presetByName(name) {
            
            systemFontSet = FontSet("_system_", fontSetPreset)
            return systemFontSet
        }
        
        return nil
    }
}
