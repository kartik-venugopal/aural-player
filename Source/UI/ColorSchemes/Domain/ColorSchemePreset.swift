import Cocoa

/*
    Enumeration of all system-defined color schemes and all their color values.
 */
enum ColorSchemePreset: String, CaseIterable {
    
    // A dark scheme with a black background (the default scheme) and lighter foreground elements.
    case blackAttack
    
    // A light scheme with an off-white background and dark foreground elements.
    case whiteBlight
    
    // A dark scheme with a black background and aqua coloring of active sliders.
    case blackAqua
    
    case lava
    
    // A semi-dark scheme with a gray background and lighter foreground elements.
    case gloomyDay
    
    // A semi-dark scheme with a brown background and lighter reddish-brown foreground elements.
    case brownie
    
    // A moderately dark scheme with a blue-ish background and lighter blue-ish foreground elements.
    case theBlues
    
    case poolsideFM
    
    // The preset to be used as the default system scheme (eg. when a user loads the app for the very first time)
    // or when some color values in a scheme are missing.
    static var defaultScheme: ColorSchemePreset {
        return blackAttack
    }
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> ColorSchemePreset? {
        
        switch name {
            
        case ColorSchemePreset.blackAttack.name:    return .blackAttack
            
        case ColorSchemePreset.blackAqua.name:    return .blackAqua
            
        case ColorSchemePreset.lava.name:    return .lava
            
        case ColorSchemePreset.whiteBlight.name:    return .whiteBlight
            
        case ColorSchemePreset.gloomyDay.name:      return .gloomyDay
            
        case ColorSchemePreset.brownie.name:      return .brownie
            
        case ColorSchemePreset.theBlues.name:   return .theBlues
            
        case ColorSchemePreset.poolsideFM.name:   return .poolsideFM
            
        default:    return nil
            
        }
    }
    
    // Returns a user-friendly display name for this preset.
    var name: String {
        
        switch self {
            
        case .blackAttack:  return "Black attack (default)"
            
        case .blackAqua:    return "Black & aqua"
            
        case .lava:         return "Lava"
            
        case .whiteBlight:  return "White blight"
            
        case .gloomyDay:    return "Gloomy day"
            
        case .brownie:         return "Brownie"
            
        case .theBlues:     return "The blues"
            
        case .poolsideFM:     return "Poolside FM"
            
        }
    }
    
    var appLogoColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .lava:     return Colors.Constants.white50Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:         return NSColor(red: 0.512, green: 0.388, blue: 0.354, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.468, green: 0.572, blue: 0.569, alpha: 1)
            
        }
    }
    
    var backgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white8Percent
            
        case .blackAqua:  return Colors.Constants.white8Percent
            
        case .lava:     return NSColor(red: 0.144, green: 0.144, blue: 0.144, alpha: 1)
            
        case .whiteBlight:  return Colors.Constants.white75Percent
            
        case .gloomyDay:    return Colors.Constants.white20Percent
            
        case .brownie:         return NSColor(red: 0.25, green: 0.162, blue: 0.131, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.191, green: 0.274, blue: 0.361, alpha: 1)
            
        case .poolsideFM:   return NSColor(red: 0.96771, green: 0.796229, blue: 0.792154, alpha: 1)
            
        }
    }
    
    var viewControlButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .lava:     return Colors.Constants.white55Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .brownie:      return NSColor(red: 0.636, green: 0.483, blue: 0.44, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.423, green: 0.501, blue: 0.549, alpha: 1)
            
        }
    }
    
    var functionButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .lava:     return Colors.Constants.white55Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .brownie:      return NSColor(red: 0.636, green: 0.483, blue: 0.44, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.423, green: 0.501, blue: 0.549, alpha: 1)
            
        }
    }
    
    var textButtonMenuColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white22Percent
            
        case .blackAqua:  return Colors.Constants.white22Percent
            
        case .lava:     return Colors.Constants.white22Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white8Percent
            
        case .brownie:         return NSColor(red: 0.5, green: 0.333, blue: 0.272, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.17, green: 0.182, blue: 0.246, alpha: 1)
            
        }
    }
    
    var toggleButtonOffStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white25Percent
            
        case .blackAqua:  return Colors.Constants.white25Percent
            
        case .lava:     return Colors.Constants.white25Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white40Percent
            
        case .gloomyDay:    return Colors.Constants.white7Percent
            
        case .brownie:         return NSColor(red: 0.384, green: 0.292, blue: 0.266, alpha: 1)
            
        case .theBlues:     return NSColor(white: 0.07, alpha: 1)
            
        }
    }
    
    var mainCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .blackAqua:  return Colors.Constants.white40Percent
            
        case .lava:     return Colors.Constants.white40Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .brownie:         return NSColor(red: 0.536, green: 0.356, blue: 0.29, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.429, green: 0.486, blue: 0.518, alpha: 1)
            
        }
    }
    
    var buttonMenuTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white75Percent
            
        case .blackAqua:  return Colors.Constants.white75Percent
            
        case .lava:     return Colors.Constants.white75Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.white
            
        case .gloomyDay:    return Colors.Constants.white75Percent
            
        case .brownie:    return NSColor(red: 0.951, green: 0.631, blue: 0.515, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.617, green: 0.7, blue: 0.746, alpha: 1)
            
        }
    }
    
    var selectedTabButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .lava:     return Colors.Constants.white50Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:    return NSColor(red: 0.701, green: 0.465, blue: 0.38, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.505, green: 0.596, blue: 0.654, alpha: 1)
            
        }
    }
    
    var tabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .blackAqua:  return Colors.Constants.white40Percent
            
        case .lava:     return Colors.Constants.white40Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white15Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .brownie:    return NSColor(red: 0.536, green: 0.356, blue: 0.29, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.429, green: 0.486, blue: 0.518, alpha: 1)
            
        }
    }
    
    var selectedTabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .blackAqua:  return Colors.Constants.white70Percent
            
        case .lava:     return Colors.Constants.white70Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white70Percent
            
        case .brownie:    return NSColor(red: 0.701, green: 0.465, blue: 0.38, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.564, green: 0.64, blue: 0.682, alpha: 1)
            
        }
    }
    
    // MARK: Player colors -------------------------------------------------------------------------------------------------------------------
    
    var playerTrackInfoPrimaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .blackAqua:  return Colors.Constants.white80Percent
            
        case .lava:     return Colors.Constants.white80Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white80Percent
            
        case .brownie:    return NSColor(red: 0.946, green: 0.628, blue: 0.513, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.693, green: 0.787, blue: 0.837, alpha: 1)
            
        }
    }
    
    var playerTrackInfoSecondaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white65Percent
            
        case .blackAqua:  return Colors.Constants.white65Percent
            
        case .lava:     return Colors.Constants.white65Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white15Percent
            
        case .gloomyDay:    return Colors.Constants.white65Percent
            
        case .brownie:    return NSColor(red: 0.74, green: 0.491, blue: 0.401, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.568, green: 0.646, blue: 0.687, alpha: 1)
            
        }
    }
    
    var playerTrackInfoTertiaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .lava:     return Colors.Constants.white55Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .brownie:    return NSColor(red: 0.636, green: 0.422, blue: 0.345, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.508, green: 0.576, blue: 0.614, alpha: 1)
            
        }
    }
    
    var playerSliderValueTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .lava:     return Colors.Constants.white50Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:    return NSColor(red: 0.74, green: 0.491, blue: 0.401, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.553, green: 0.627, blue: 0.668, alpha: 1)
            
        }
    }
    
    var playerSliderForegroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .lava:     return Colors.Constants.lava
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:    return NSColor(red: 0.8, green: 0.329, blue: 0.293, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.313, green: 0.548, blue: 0.756, alpha: 1)
            
        }
    }
    
    var playerSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .blackAqua:  return .darken
            
        case .lava:     return .brighten
            
        case .whiteBlight, .poolsideFM:  return .none
            
        case .gloomyDay:    return .darken
            
        case .brownie:    return .darken
            
        case .theBlues:     return .darken
            
        }
    }
    
    var playerSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 70
            
        case .blackAqua:  return 60
            
        case .lava:     return 60
            
        case .whiteBlight, .poolsideFM:  return 20
            
        case .gloomyDay:    return 50
            
        case .brownie:    return 50
            
        case .theBlues:     return 40
            
        }
    }
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white20Percent
            
        case .blackAqua:  return Colors.Constants.white20Percent
            
        case .lava:     return NSColor(red: 0.326, green: 0.326, blue: 0.326, alpha: 1)
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white60Percent
            
        case .gloomyDay:    return Colors.Constants.white8Percent
            
        case .brownie:    return NSColor.black
            
        case .theBlues:     return Colors.Constants.white8Percent
            
        }
    }
    
    var playerSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .none
            
        case .blackAqua:  return .none
            
        case .lava:     return .darken
            
        case .whiteBlight, .poolsideFM:  return .none
            
        case .gloomyDay:    return .none
            
        case .brownie:         return .none
            
        case .theBlues:     return .none
            
        }
    }
    
    var playerSliderBackgroundGradientAmount: Int {
        
        switch self {
        
        case .lava:     return 36
            
        default:        return 20
            
        }
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .lava:     return Colors.Constants.lava
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:    return NSColor(red: 0.8, green: 0.329, blue: 0.293, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.313, green: 0.548, blue: 0.756, alpha: 1)
            
        }
    }
    
    var playerSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var playerSliderLoopSegmentColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .blackAqua:  return Colors.Constants.white60Percent
            
        case .lava:     return Colors.Constants.white60Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white40Percent
            
        case .gloomyDay:    return Colors.Constants.white60Percent
            
        case .brownie:    return NSColor(red: 0.75, green: 0.452, blue: 0.43, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.381, green: 0.667, blue: 0.924, alpha: 1)
            
        }
    }
    
    // MARK: Playlist colors ------------------------------------------------------------------------------------------------------
    
    var playlistTrackNameTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .lava:  return Colors.Constants.white50Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .brownie:    return NSColor(red: 0.614, green: 0.407, blue: 0.332, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.524, green: 0.595, blue: 0.634, alpha: 1)
            
        }
    }
    
    var playlistGroupNameTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .blackAqua:  return Colors.Constants.white40Percent
            
        case .lava:  return Colors.Constants.white40Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .brownie:    return NSColor(red: 0.519, green: 0.345, blue: 0.281, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.473, green: 0.536, blue: 0.572, alpha: 1)
            
        }
    }
    
    var playlistIndexDurationTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white30Percent
            
        case .blackAqua:  return Colors.Constants.white30Percent
            
        case .lava:  return Colors.Constants.white30Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white45Percent
            
        case .gloomyDay:    return Colors.Constants.white37Percent
            
        case .brownie:    return NSColor(red: 0.448, green: 0.297, blue: 0.243, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.429, green: 0.486, blue: 0.518, alpha: 1)
            
        }
    }
    
    var playlistTrackNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .blackAqua:  return Colors.Constants.white80Percent
            
        case .lava:  return Colors.Constants.white80Percent
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.white80Percent
            
        case .brownie:    return NSColor(red: 0.856, green: 0.346, blue: 0.286, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.597, green: 0.715, blue: 0.829, alpha: 1)
            
        }
    }
    
    var playlistGroupNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .blackAqua:  return Colors.Constants.white55Percent
            
        case .lava:  return Colors.Constants.white55Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white15Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .brownie:    return NSColor(red: 0.744, green: 0.301, blue: 0.247, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.508, green: 0.608, blue: 0.705, alpha: 1)
            
        }
    }
    
    var playlistIndexDurationSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .lava:  return Colors.Constants.white50Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:    return NSColor(red: 0.668, green: 0.271, blue: 0.221, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.424, green: 0.508, blue: 0.59, alpha: 1)
            
        }
    }
    
    var playlistGroupIconColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white35Percent
            
        case .blackAqua:  return Colors.Constants.white35Percent
            
        case .lava:  return Colors.Constants.white35Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white30Percent
            
        case .gloomyDay:    return Colors.Constants.white40Percent
            
        case .brownie:    return NSColor(red: 0.5, green: 0.332, blue: 0.271, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.37, green: 0.431, blue: 0.534, alpha: 1)
            
        }
    }
    
    var playlistGroupDisclosureTriangleColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .blackAqua:  return Colors.Constants.white60Percent
            
        case .lava:  return Colors.Constants.white60Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white60Percent
            
        case .brownie:    return NSColor(red: 0.608, green: 0.403, blue: 0.329, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.429, green: 0.5, blue: 0.618, alpha: 1)
            
        }
    }
    
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white15Percent
            
        case .blackAqua:  return Colors.Constants.white15Percent
            
        case .lava:  return NSColor.black
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white60Percent
            
        case .gloomyDay:    return Colors.Constants.white10Percent
            
        case .brownie:    return NSColor(red: 0.073, green: 0.047, blue: 0.038, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.079, green: 0.139, blue: 0.192, alpha: 1)
            
        }
    }
    
    var playlistPlayingTrackIconColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .lava:     return Colors.Constants.lava
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.aqua
            
        case .brownie:    return NSColor(red: 0.856, green: 0.346, blue: 0.286, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.313, green: 0.548, blue: 0.756, alpha: 1)
            
        }
    }
    
    var playlistSummaryInfoColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .blackAqua:  return Colors.Constants.white50Percent
            
        case .lava:     return Colors.Constants.white50Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white50Percent
            
        case .brownie:    return NSColor(red: 0.622, green: 0.412, blue: 0.337, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.477, green: 0.541, blue: 0.576, alpha: 1)
            
        }
    }
    
    // Effects color scheme ------------------------------------------------------------------------------------------------------------------------------
    
    var effectsFunctionCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white45Percent
            
        case .blackAqua:  return Colors.Constants.white45Percent
            
        case .lava:  return Colors.Constants.white45Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white25Percent
            
        case .gloomyDay:    return Colors.Constants.white45Percent
            
        case .brownie:    return NSColor(red: 0.614, green: 0.407, blue: 0.333, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.491, green: 0.557, blue: 0.593, alpha: 1)
            
        }
    }
    
    var effectsFunctionValueTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .blackAqua:  return Colors.Constants.white70Percent
            
        case .lava:     return Colors.Constants.white70Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white10Percent
            
        case .gloomyDay:    return Colors.Constants.white70Percent
            
        case .brownie:    return NSColor(red: 0.805, green: 0.534, blue: 0.436, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.617, green: 0.7, blue: 0.746, alpha: 1)
            
        }
    }
    
    var effectsSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white15Percent
            
        case .blackAqua:  return Colors.Constants.white15Percent
            
        case .lava:     return NSColor(red: 0.326, green: 0.326, blue: 0.326, alpha: 1)
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white60Percent
            
        case .gloomyDay:    return Colors.Constants.white25Percent
            
        case .brownie:    return NSColor(red: 0.592, green: 0.381, blue: 0.309, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.395, green: 0.416, blue: 0.416, alpha: 1)
            
        }
    }
  
    var effectsSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .brighten
            
        case .blackAqua:  return .brighten
            
        case .lava:  return .darken
            
        case .whiteBlight, .poolsideFM:  return .none
            
        case .gloomyDay:    return .brighten
            
        case .brownie:    return .darken
            
        case .theBlues:     return .darken
            
        }
    }
    
    var effectsSliderBackgroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 20
            
        case .blackAqua:  return 20
            
        case .lava:     return 36
            
        case .whiteBlight, .poolsideFM:  return 0
            
        case .gloomyDay:    return 15
            
        case .brownie:    return 50
            
        case .theBlues:     return 40
            
        }
    }
    
    var effectsSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .lava:     return Colors.Constants.lava
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.aqua
            
        case .brownie:    return NSColor(red: 0.8, green: 0.329, blue: 0.293, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0, green: 0.568, blue: 0.756, alpha: 1)
            
        }
    }
    
    var effectsSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var effectsSliderTickColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor.black
            
        case .blackAqua:  return NSColor.black
            
        case .lava:     return NSColor.black
            
        case .whiteBlight, .poolsideFM:  return NSColor.white
            
        case .gloomyDay:    return NSColor.black
            
        case .brownie:         return NSColor.black
            
        case .theBlues:     return NSColor.black
            
        }
    }
    
    var effectsActiveUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green75Percent
            
        case .blackAqua:  return Colors.Constants.aqua
            
        case .lava:     return Colors.Constants.lava
            
        case .whiteBlight, .poolsideFM:  return NSColor.black
            
        case .gloomyDay:    return Colors.Constants.aqua
            
        case .brownie:    return NSColor(red: 0.8, green: 0.329, blue: 0.293, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0, green: 0.568, blue: 0.756, alpha: 1)
            
        }
    }
    
    var effectsBypassedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .blackAqua:  return Colors.Constants.white60Percent
            
        case .lava:  return Colors.Constants.white60Percent
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white40Percent
            
        case .gloomyDay:    return Colors.Constants.white55Percent
            
        case .brownie:    return NSColor(red: 0.668, green: 0.507, blue: 0.436, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0.446, green: 0.505, blue: 0.539, alpha: 1)
            
        }
    }
    
    var effectsSuppressedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor(red: 0.76, green: 0.69, blue: 0, alpha: 1)
            
        case .blackAqua:  return NSColor(red: 0, green: 0.31, blue: 0.5, alpha: 1)
            
        case .lava:  return NSColor(red: 0.5, green: 0.204, blue: 0.107, alpha: 1)
            
        case .whiteBlight, .poolsideFM:  return Colors.Constants.white20Percent
            
        case .gloomyDay:    return NSColor(red: 0, green: 0.4, blue: 0.65, alpha: 1)
            
        case .brownie:    return NSColor(red: 0.599, green: 0.245, blue: 0.217, alpha: 1)
            
        case .theBlues:     return NSColor(red: 0, green: 0.4, blue: 0.65, alpha: 1)
            
        }
    }
    
    var effectsSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .blackAqua:    return .darken
            
        case .lava:         return .brighten
            
        case .whiteBlight, .poolsideFM:  return .brighten
            
        case .gloomyDay:    return .darken
            
        case .brownie:      return .darken
            
        case .theBlues:     return .darken
            
        }
    }
    
    var effectsSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 60
            
        case .blackAqua:    return 60
            
        case .lava:         return 60
            
        case .whiteBlight, .poolsideFM:  return 30
            
        case .gloomyDay:    return 60
            
        case .brownie:      return 50
            
        case .theBlues:     return 45
            
        }
    }
}
