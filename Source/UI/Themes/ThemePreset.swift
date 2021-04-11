import Cocoa

/*
    Enumeration of all system-defined color schemes and all their color values.
 */
enum ThemePreset: String, CaseIterable {
    
    // A dark scheme with a black background (the default scheme) and lighter foreground elements.
    case poolsideFM
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> ColorSchemePreset? {
        
        switch name {
            
        case ColorSchemePreset.blackAttack.name:    return .blackAttack
        
        default:    return nil
            
        }
    }
    
    // Returns a user-friendly display name for this preset.
    var name: String {
        
        switch self {
            
        case .poolsideFM:  return "Poolside.fm"
            
        }
    }
    
//    var fontScheme: FontScheme {
//        
//    }
//    
    var colorScheme: ColorScheme {
     
        switch self {
        
        case .poolsideFM:   return ColorScheme(self.name, .poolsideFM)
            
        }
    }
}
