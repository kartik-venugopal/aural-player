import Cocoa

enum ColorSchemePreset: String, CaseIterable {
    
    case blackAttack
    
    case whiteBlight
    
    static var defaultScheme: ColorSchemePreset {
        return blackAttack
    }
    
    var name: String {
        
        switch self {
            
        case .blackAttack:  return "Black attack (default)"
            
        case .whiteBlight:  return "White blight"
            
        }
    }
    
    var appLogoColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var backgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor.black
            
        case .whiteBlight:  return Colors.Constants.white90Percent
            
        }
    }
    
    var viewControlButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var functionButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var textButtonMenuColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white25Percent
            
        case .whiteBlight:  return Colors.Constants.white60Percent
            
        }
    }
    
    var toggleButtonOffStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white35Percent
            
        case .whiteBlight:  return Colors.Constants.white60Percent
            
        }
    }
    
    var mainCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .whiteBlight:  return Colors.Constants.white40Percent
            
        }
    }
    
    var buttonMenuTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .whiteBlight:  return NSColor.white
            
        }
    }
    
    var selectedTabButtonColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white15Percent
            
        case .whiteBlight:  return Colors.Constants.white75Percent
            
        }
    }
    
    var tabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return Colors.Constants.white15Percent
            
        }
    }
    
    var selectedTabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    // MARK: Player colors -------------------------------------------------------------------------------------------------------------------
    
    var playerTrackInfoPrimaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white80Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var playerTrackInfoSecondaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white65Percent
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playerTrackInfoTertiaryTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playerSliderValueTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white55Percent
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playerSliderForegroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var playerSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .whiteBlight:  return .none
            
        }
    }
    
    var playerSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 60
            
        case .whiteBlight:  return 20
            
        }
    }
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white25Percent
            
        case .whiteBlight:  return Colors.Constants.white55Percent
            
        }
    }
    
    var playerSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .none
            
        case .whiteBlight:  return .none
            
        }
    }
    
    var playerSliderBackgroundGradientAmount: Int {
        return 20
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white65Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var playerSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var playerSliderLoopSegmentColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.green60Percent
            
        case .whiteBlight:  return Colors.Constants.green60Percent
            
        }
    }
    
    // MARK: Playlist colors ------------------------------------------------------------------------------------------------------
    
    var playlistTrackNameTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white65Percent
            
        case .whiteBlight:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playlistGroupNameTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white45Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistIndexDurationTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .whiteBlight:  return Colors.Constants.white45Percent
            
        }
    }
    
    var playlistTrackNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white90Percent
            
        case .whiteBlight:  return Colors.Constants.white10Percent
            
        }
    }
    
    var playlistGroupNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return Colors.Constants.white25Percent
            
        }
    }
    
    var playlistIndexDurationSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white60Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistGroupIconColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistGroupDisclosureTriangleColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white40Percent
            
        case .whiteBlight:  return Colors.Constants.white50Percent
            
        }
    }
    
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white15Percent
            
        case .whiteBlight:  return Colors.Constants.white75Percent
            
        }
    }
    
    var playlistPlayingTrackIconColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var playlistSummaryInfoColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        }
    }
    
    // Effects color scheme ------------------------------------------------------------------------------------------------------------------------------
    
    var effectsFunctionCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white40Percent
            
        }
    }
    
    var effectsFunctionValueTextColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white70Percent
            
        case .whiteBlight:  return Colors.Constants.white15Percent
            
        }
    }
    
    var effectsSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white30Percent
            
        case .whiteBlight:  return Colors.Constants.white70Percent
            
        }
    }
  
    var effectsSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .whiteBlight:  return .brighten
            
        }
    }
    
    var effectsSliderBackgroundGradientAmount: Int {
        return 20
    }
    
    var effectsSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var effectsSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var effectsSliderTickColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor.black
            
        case .whiteBlight:  return NSColor.white
            
        }
    }
    
    var effectsActiveUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor(red: 0, green: 0.75, blue: 0, alpha: 1)
            
        case .whiteBlight:  return NSColor.black
            
        }
    }
    
    var effectsBypassedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return Colors.Constants.white50Percent
            
        case .whiteBlight:  return Colors.Constants.white50Percent
            
        }
    }
    
    var effectsSuppressedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackAttack:  return NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
            
        case .whiteBlight:  return Colors.Constants.white30Percent
            
        }
    }
    
    var effectsSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackAttack:  return .darken
            
        case .whiteBlight:  return .brighten
            
        }
    }
    
    var effectsSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .blackAttack:  return 50
            
        case .whiteBlight:  return 40
            
        }
    }
    
}
