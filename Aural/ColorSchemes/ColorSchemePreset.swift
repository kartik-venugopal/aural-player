import Cocoa

enum ColorSchemePreset: String, CaseIterable {
    
    case darkMode
    
    case lightMode
    
    static var defaultScheme: ColorSchemePreset {
        return darkMode
    }
    
    var name: String {
        
        switch self {
            
        case .darkMode:  return "Dark mode (default)"
            
        case .lightMode:  return "White blight"
            
        }
    }
    
    var appLogoColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white60Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var backgroundColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white15Percent
            
        case .lightMode:  return Colors.Constants.white90Percent
            
        }
    }
    
    var viewControlButtonColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white70Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var functionButtonColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white70Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var textButtonMenuColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white40Percent
            
        case .lightMode:  return Colors.Constants.white60Percent
            
        }
    }
    
    var toggleButtonOffStateColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white35Percent
            
        case .lightMode:  return Colors.Constants.white60Percent
            
        }
    }
    
    var mainCaptionTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white50Percent
            
        case .lightMode:  return Colors.Constants.white40Percent
            
        }
    }
    
    var buttonMenuTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white80Percent
            
        case .lightMode:  return NSColor.white
            
        }
    }
    
    var selectedTabButtonColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor.black
            
        case .lightMode:  return Colors.Constants.white75Percent
            
        }
    }
    
    var tabButtonTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white60Percent
            
        case .lightMode:  return Colors.Constants.white15Percent
            
        }
    }
    
    var selectedTabButtonTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white80Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    // MARK: Player colors -------------------------------------------------------------------------------------------------------------------
    
    var playerTrackInfoPrimaryTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white80Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var playerTrackInfoSecondaryTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white65Percent
            
        case .lightMode:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playerTrackInfoTertiaryTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white55Percent
            
        case .lightMode:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playerSliderValueTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white55Percent
            
        case .lightMode:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playerSliderForegroundColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white65Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var playerSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .darkMode:  return .darken
            
        case .lightMode:  return .none
            
        }
    }
    
    var playerSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .darkMode:  return 60
            
        case .lightMode:  return 20
            
        }
    }
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white30Percent
            
        case .lightMode:  return Colors.Constants.white55Percent
            
        }
    }
    
    var playerSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .darkMode:  return .brighten
            
        case .lightMode:  return .none
            
        }
    }
    
    var playerSliderBackgroundGradientAmount: Int {
        return 20
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white65Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var playerSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var playerSliderLoopSegmentColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
            
        case .lightMode:  return NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
            
        }
    }
    
    // MARK: Playlist colors ------------------------------------------------------------------------------------------------------
    
    var playlistTrackNameTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white60Percent
            
        case .lightMode:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playlistGroupNameTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white50Percent
            
        case .lightMode:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistIndexDurationTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white40Percent
            
        case .lightMode:  return Colors.Constants.white45Percent
            
        }
    }
    
    var playlistTrackNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white90Percent
            
        case .lightMode:  return Colors.Constants.white10Percent
            
        }
    }
    
    var playlistGroupNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white70Percent
            
        case .lightMode:  return Colors.Constants.white25Percent
            
        }
    }
    
    var playlistIndexDurationSelectedTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white60Percent
            
        case .lightMode:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistGroupIconColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white70Percent
            
        case .lightMode:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistGroupDisclosureTriangleColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white40Percent
            
        case .lightMode:  return Colors.Constants.white50Percent
            
        }
    }
    
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor.black
            
        case .lightMode:  return Colors.Constants.white75Percent
            
        }
    }
    
    var playlistPlayingTrackIconColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var playlistSummaryInfoColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white50Percent
            
        case .lightMode:  return Colors.Constants.white30Percent
            
        }
    }
    
    // Effects color scheme ------------------------------------------------------------------------------------------------------------------------------
    
    var effectsFunctionCaptionTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white50Percent
            
        case .lightMode:  return Colors.Constants.white40Percent
            
        }
    }
    
    var effectsFunctionValueTextColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white70Percent
            
        case .lightMode:  return Colors.Constants.white15Percent
            
        }
    }
    
    var effectsSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white30Percent
            
        case .lightMode:  return Colors.Constants.white70Percent
            
        }
    }
  
    var effectsSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .darkMode:  return .darken
            
        case .lightMode:  return .brighten
            
        }
    }
    
    var effectsSliderBackgroundGradientAmount: Int {
        return 20
    }
    
    var effectsSliderKnobColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white50Percent
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var effectsSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var effectsSliderTickColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor.black
            
        case .lightMode:  return NSColor.white
            
        }
    }
    
    var effectsActiveUnitStateColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
            
        case .lightMode:  return NSColor.black
            
        }
    }
    
    var effectsBypassedUnitStateColor: NSColor {
        
        switch self {
            
        case .darkMode:  return Colors.Constants.white50Percent
            
        case .lightMode:  return Colors.Constants.white50Percent
            
        }
    }
    
    var effectsSuppressedUnitStateColor: NSColor {
        
        switch self {
            
        case .darkMode:  return NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
            
        case .lightMode:  return Colors.Constants.white30Percent
            
        }
    }
    
    var effectsSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .darkMode:  return .darken
            
        case .lightMode:  return .brighten
            
        }
    }
    
    var effectsSliderForegroundGradientAmount: Int {
        
        switch self {
            
        case .darkMode:  return 50
            
        case .lightMode:  return 40
            
        }
    }
    
}
