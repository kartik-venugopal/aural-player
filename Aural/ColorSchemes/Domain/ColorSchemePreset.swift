import Cocoa

enum ColorSchemePreset: String, CaseIterable {
    
    case blackAttack
    
    case whiteBlight
    
    case blackAqua
    
    case gloomyDay
    
    case wood
    
    static var defaultScheme: ColorSchemePreset {
        return blackAttack
    }
    
    static func presetByName(_ name: String) -> ColorSchemePreset? {
        
        switch name {
            
        case ColorSchemePreset.blackAttack.name:    return .blackAttack
            
        case ColorSchemePreset.blackAqua.name:    return .blackAqua
            
        case ColorSchemePreset.whiteBlight.name:    return .whiteBlight
            
        case ColorSchemePreset.gloomyDay.name:      return .gloomyDay
            
        case ColorSchemePreset.wood.name:      return .wood
            
        default:    return nil
            
        }
    }
    
    var name: String {
        
        switch self {
            
        case .blackAttack:  return "Black attack (default)"
            
        case .blackAqua:    return "Black & aqua"
            
        case .whiteBlight:  return "White blight"
            
        case .gloomyDay:    return "Gloomy day"
            
        case .wood:         return "Wood"
            
        }
    }
    
    var appLogoColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:         return NSColor(red: 0.79, green: 0.51, blue: 0.33, alpha: 1)
            
        }
    }
    
    var backgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white8Percent
            
        case .blackAqua:  return Colors.Constants.white8Percent
            
        case .whiteBlight:  return Colors.Constants.white75Percent
            
        case .gloomyDay:    return Colors.Constants.white20Percent
            
        case .wood:         return NSColor(red: 0.25, green: 0.14, blue: 0.06, alpha: 1)
            
        }
    }
    
    var viewControlButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .wood:         return NSColor(red: 0.79, green: 0.51, blue: 0.33, alpha: 1)
            
        }
    }
    
    var functionButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .wood:         return NSColor(red: 0.79, green: 0.51, blue: 0.33, alpha: 1)
            
        }
    }
    
    var textButtonMenuColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white22Percent
            
        case .blackAqua:  return Colors.Constants.white22Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white8Percent
            
        case .wood:         return NSColor(red: 0.46, green: 0.26, blue: 0.107, alpha: 1)
            
        }
    }
    
    var toggleButtonOffStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white25Percent
            
        case .blackAqua:  return Colors.Constants.white25Percent
            
        case .whiteBlight:  return Colors.Constants.white40Percent
            
        case .gloomyDay:    return Colors.Constants.white7Percent
            
        case .wood:         return NSColor(red: 0.46, green: 0.26, blue: 0.107, alpha: 1)
            
        }
    }
    
    var mainCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .blackAqua:  return Colors.Constants.white40Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .wood:         return NSColor(red: 0.59, green: 0.33, blue: 0.136, alpha: 1)
            
        }
    }
    
    var buttonMenuTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white75Percent
            
        case .blackAqua:  return Colors.Constants.white75Percent
            
        case .whiteBlight:  return NSColor.white
            
        case .gloomyDay:    return Colors.Constants.white75Percent
            
        case .wood:    return Colors.Constants.white75Percent
            
        }
    }
    
    var selectedTabButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:    return NSColor(red: 0.737, green: 0.414, blue: 0.17, alpha: 1)
            
        }
    }
    
    var tabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .blackAqua:  return Colors.Constants.white40Percent
            
        case .whiteBlight:  return Colors.Constants.white15Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .wood:    return NSColor(red: 0.59, green: 0.33, blue: 0.136, alpha: 1)
            
        }
    }
    
    var selectedTabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .blackAqua:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white70Percent
            
        case .wood:    return NSColor(red: 0.737, green: 0.414, blue: 0.17, alpha: 1)
            
        }
    }
    
    // MARK: Player colors -------------------------------------------------------------------------------------------------------------------
    
    var playerTrackInfoPrimaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .blackAqua:  return Colors.Constants.white80Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white80Percent
            
        case .wood:    return NSColor(red: 0.87, green: 0.76, blue: 0.63, alpha: 1)
            
        }
    }
    
    var playerTrackInfoSecondaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white65Percent
            
        case .blackAqua:  return Colors.Constants.white65Percent
            
        case .whiteBlight:  return Colors.Constants.white15Percent
            
        case .gloomyDay:    return Colors.Constants.white65Percent
            
        case .wood:    return NSColor(red: 0.71, green: 0.62, blue: 0.518, alpha: 1)
            
        }
    }
    
    var playerTrackInfoTertiaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .whiteBlight:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .wood:    return NSColor(red: 0.61, green: 0.53, blue: 0.44, alpha: 1)
            
        }
    }
    
    var playerSliderValueTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:    return NSColor(red: 0.66, green: 0.58, blue: 0.48, alpha: 1)
            
        }
    }
    
    var playerSliderForegroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:    return NSColor(red: 0.795, green: 0.447, blue: 0.183, alpha: 1)
            
        }
    }
    
    var playerSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .blackAqua:  return .darken
            
        case .whiteBlight:  return .none
            
        case .gloomyDay:    return .darken
            
        case .wood:    return .darken
            
        }
    }
    
    var playerSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 70
            
        case .blackAqua:  return 60
            
        case .whiteBlight:  return 20
            
        case .gloomyDay:    return 50
            
        case .wood:    return 50
            
        }
    }
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white20Percent
            
        case .blackAqua:  return Colors.Constants.white20Percent
            
        case .whiteBlight:  return Colors.Constants.white60Percent
            
        case .gloomyDay:    return Colors.Constants.white8Percent
            
        case .wood:    return NSColor.black
            
        }
    }
    
    var playerSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .none
            
        case .blackAqua:  return .none
            
        case .whiteBlight:  return .none
            
        case .gloomyDay:    return .none
            
        case .wood:         return .none
            
        }
    }
    
    var playerSliderBackgroundGradientAmount: Int {
        return 20
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:    return NSColor(red: 0.795, green: 0.447, blue: 0.183, alpha: 1)
            
        }
    }
    
    var playerSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var playerSliderLoopSegmentColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .blackAqua:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return Colors.Constants.white40Percent
            
        case .gloomyDay:    return Colors.Constants.white60Percent
            
        case .wood:    return NSColor(red: 0.75, green: 0.452, blue: 0.43, alpha: 1)
            
        }
    }
    
    // MARK: Playlist colors ------------------------------------------------------------------------------------------------------
    
    var playlistTrackNameTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .wood:    return NSColor(red: 0.618, green: 0.51, blue: 0.4, alpha: 1)
            
        }
    }
    
    var playlistGroupNameTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .blackAqua:  return Colors.Constants.white40Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .wood:    return NSColor(red: 0.545, green: 0.45, blue: 0.35, alpha: 1)
            
        }
    }
    
    var playlistIndexDurationTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white30Percent
            
        case .blackAqua:  return Colors.Constants.white30Percent
            
        case .whiteBlight:  return Colors.Constants.white45Percent
            
        case .gloomyDay:    return Colors.Constants.white37Percent
            
        case .wood:    return NSColor(red: 0.426, green: 0.35, blue: 0.276, alpha: 1)
            
        }
    }
    
    var playlistTrackNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .blackAqua:  return Colors.Constants.white80Percent
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white80Percent
            
        case .wood:    return NSColor(red: 0.91, green: 0.51, blue: 0.21, alpha: 1)
            
        }
    }
    
    var playlistGroupNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .whiteBlight:  return Colors.Constants.white15Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .wood:    return NSColor(red: 0.71, green: 0.586, blue: 0.457, alpha: 1)
            
        }
    }
    
    var playlistIndexDurationSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:    return NSColor(red: 0.586, green: 0.483, blue: 0.376, alpha: 1)
            
        }
    }
    
    var playlistGroupIconColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white35Percent
            
        case .blackAqua:  return Colors.Constants.white35Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white40Percent
            
        case .wood:    return NSColor(red: 0.63, green: 0.355, blue: 0.146, alpha: 1)
            
        }
    }
    
    var playlistGroupDisclosureTriangleColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .blackAqua:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white60Percent
            
        case .wood:    return NSColor(red: 0.718, green: 0.403, blue: 0.165, alpha: 1)
            
        }
    }
    
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white15Percent
            
        case .blackAqua:  return Colors.Constants.white15Percent
            
        case .whiteBlight:  return Colors.Constants.white60Percent
            
        case .gloomyDay:    return Colors.Constants.white10Percent
            
        case .wood:    return NSColor(red: 0.073, green: 0.041, blue: 0.017, alpha: 1)
            
        }
    }
    
    var playlistPlayingTrackIconColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.aqua
            
        case .wood:    return NSColor(red: 0.91, green: 0.51, blue: 0.21, alpha: 1)
            
        }
    }
    
    var playlistSummaryInfoColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .wood:    return NSColor(red: 0.737, green: 0.414, blue: 0.17, alpha: 1)
            
        }
    }
    
    // Effects color scheme ------------------------------------------------------------------------------------------------------------------------------
    
    var effectsFunctionCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white45Percent
            
        case .blackAqua:  return Colors.Constants.white45Percent
            
        case .whiteBlight:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .wood:    return NSColor(red: 0.681, green: 0.383, blue: 0.157, alpha: 1)
            
        }
    }
    
    var effectsFunctionValueTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .blackAqua:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return Colors.Constants.white10Percent
            
        case .gloomyDay:    return Colors.Constants.white70Percent
            
        case .wood:    return NSColor(red: 0.859, green: 0.483, blue: 0.198, alpha: 1)
            
        }
    }
    
    var effectsSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white15Percent
            
        case .blackAqua:  return Colors.Constants.white15Percent
            
        case .whiteBlight:  return Colors.Constants.white60Percent
            
        case .gloomyDay:    return Colors.Constants.white25Percent
            
        case .wood:    return NSColor(red: 0.287, green: 0.19, blue: 0.081, alpha: 1)
            
        }
    }
  
    var effectsSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .brighten
            
        case .blackAqua:  return .brighten
            
        case .whiteBlight:  return .none
            
        case .gloomyDay:    return .brighten
            
        case .wood:    return .brighten
            
        }
    }
    
    var effectsSliderBackgroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 20
            
        case .blackAqua:  return 20
            
        case .whiteBlight:  return 0
            
        case .gloomyDay:    return 15
            
        case .wood:    return 20
            
        }
    }
    
    var effectsSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.aqua
            
        case .wood:    return NSColor(red: 0.854, green: 0.579, blue: 0.457, alpha: 1)
            
        }
    }
    
    var effectsSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var effectsSliderTickColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor.black
            
        case .blackAqua:  return NSColor.black
            
        case .whiteBlight:  return NSColor.white
            
        case .gloomyDay:    return NSColor.black
            
        case .wood:         return NSColor.black
            
        }
    }
    
    var effectsActiveUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .whiteBlight:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.aqua
            
        case .wood:    return NSColor(red: 0.91, green: 0.51, blue: 0.21, alpha: 1)
            
        }
    }
    
    var effectsBypassedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .blackAqua:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return Colors.Constants.white40Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .wood:    return NSColor(red: 0.668, green: 0.586, blue: 0.488, alpha: 1)
            
        }
    }
    
    var effectsSuppressedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor(red: 0.76, green: 0.69, blue: 0, alpha: 1)
            
        case .blackAqua:  return NSColor(red: 0, green: 0.31, blue: 0.5, alpha: 1)
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return NSColor(red: 0, green: 0.4, blue: 0.65, alpha: 1)
            
        case .wood:    return NSColor(red: 0.645, green: 0.362, blue: 0.149, alpha: 1)
            
        }
    }
    
    var effectsSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .blackAqua:  return .darken
            
        case .whiteBlight:  return .brighten
            
        case .gloomyDay:    return .darken
            
        case .wood:         return .darken
            
        }
    }
    
    var effectsSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 60
            
        case .blackAqua:  return 60
            
        case .whiteBlight:  return 30
            
        case .gloomyDay:    return 60
            
        case .wood:         return 60
            
        }
    }
}
