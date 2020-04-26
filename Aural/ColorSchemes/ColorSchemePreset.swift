import Cocoa

enum ColorSchemePreset: String, CaseIterable {
    
    case blackBackgroundWhiteForeground
    
    case whiteBackgroundBlackForeground
    
    static var defaultScheme: ColorSchemePreset {
        return blackBackgroundWhiteForeground
    }
    
    var description: String {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return "Black background, white foreground"
            
        case .whiteBackgroundBlackForeground:  return "White background, black foreground"
            
        }
    }
    
    var appLogoColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white80Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.black
            
        }
    }
    
    var backgroundColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return NSColor.black
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white80Percent
            
        }
    }
    
    var viewControlButtonColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.black
            
        }
    }
    
    var functionButtonColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.black
            
        }
    }
    
    var textButtonMenuColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.black
            
        }
    }
    
    var toggleButtonOffStateColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white20Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white60Percent
            
        }
    }
    
    var buttonMenuTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white70Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white70Percent
            
        }
    }
    
    var selectedTabButtonColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white15Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white70Percent
            
        }
    }
    
    var tabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white70Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    var selectedTabButtonTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white90Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white10Percent
            
        }
    }
    
    // MARK: Player colors -------------------------------------------------------------------------------------------------------------------
    
    var playerTrackInfoPrimaryTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white50Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playerTrackInfoSecondaryTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playerTrackInfoTertiaryTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white70Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white10Percent
            
        }
    }
    
    var playerSliderValueTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.darkGray
            
        }
    }
    
    var playerSliderForegroundColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.darkGray
            
        }
    }
    
    var playerSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return .darken
            
        case .whiteBackgroundBlackForeground:  return .brighten
            
        }
    }
    
    var playerSliderForegroundGradientAmount: Int {
        return 40
    }
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white20Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white50Percent
            
        }
    }
    
    var playerSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return .brighten
            
        case .whiteBackgroundBlackForeground:  return .darken
            
        }
    }
    
    var playerSliderBackgroundGradientAmount: Int {
        return 40
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white50Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.darkGray
            
        }
    }
    
    var playerSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var playerSliderLoopSegmentColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
            
        case .whiteBackgroundBlackForeground:  return NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
            
        }
    }
    
    // MARK: Playlist colors ------------------------------------------------------------------------------------------------------
    
    var playlistTrackNameTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white70Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playlistGroupNameTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    var playlistIndexDurationTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white40Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white60Percent
            
        }
    }
    
    var playlistTrackNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return NSColor.white
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white10Percent
            
        }
    }
    
    var playlistGroupNameSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white80Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playlistIndexDurationSelectedTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white20Percent
            
        }
    }
    
    var playlistGroupIconColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white50Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white50Percent
            
        }
    }
    
    var playlistGroupDisclosureTriangleColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white40Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white60Percent
            
        }
    }
    
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white15Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white70Percent
            
        }
    }
    
    var playlistPlayingTrackIconColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
            
        case .whiteBackgroundBlackForeground:  return NSColor(red: 0, green: 0.425, blue: 0, alpha: 1)
            
        }
    }
    
    var playlistSummaryInfoColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white70Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    // Effects color scheme ------------------------------------------------------------------------------------------------------------------------------
    
    var mainCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white50Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white15Percent
            
        }
    }
    
    var effectsFunctionCaptionTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    var effectsFunctionValueTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    var effectsSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white40Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white70Percent
            
        }
    }
  
    var effectsSliderBackgroundGradientType: GradientType {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return .darken
            
        case .whiteBackgroundBlackForeground:  return .brighten
            
        }
    }
    
    var effectsSliderBackgroundGradientAmount: Int {
        return 40
    }
    
    var effectsSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white50Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.darkGray
            
        }
    }
    
    var effectsSliderKnobColorSameAsForeground: Bool {
        return true
    }
    
    var effectsActiveUnitStateColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white70Percent
            
        }
    }
    
    var effectsBypassedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white60Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white30Percent
            
        }
    }
    
    var effectsSuppressedUnitStateColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white70Percent
            
        }
    }
    
    var effectsSliderForegroundGradientType: GradientType {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return .darken
            
        case .whiteBackgroundBlackForeground:  return .brighten
            
        }
    }
    
    var effectsSliderForegroundGradientAmount: Int {
        return 40
    }
    
}
