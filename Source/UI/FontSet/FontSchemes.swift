import Cocoa

class FontSchemes {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultFontScheme: FontScheme = FontScheme("_default_", FontSchemePreset.standard)
    
    // The current system color scheme. It is initialized with the default scheme.
    static var systemFontScheme: FontScheme = defaultFontScheme
    
    static func initialize() {
        _ = systemFontScheme
    }
    
    static func applyFontScheme(named name: String) -> FontScheme? {
        
        if let fontSchemePreset = FontSchemePreset.presetByName(name) {
            
            systemFontScheme = FontScheme("_system_", fontSchemePreset)
            return systemFontScheme
        }
        
        return nil
    }
    
    static func applyFontScheme(_ fontScheme: FontScheme) -> FontScheme {

        systemFontScheme = fontScheme.clone()
        return systemFontScheme
    }
}
