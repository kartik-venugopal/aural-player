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
    
    var logoTextColor: NSColor {
        
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
    
    var controlButtonColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white80Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.black
            
        }
    }
    
    var controlButtonOffStateColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white20Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white60Percent
            
        }
    }
    
    var primaryTextColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white80Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.black
            
        }
    }
    
    var secondaryTextColor: NSColor {
        
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
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white20Percent
            
        case .whiteBackgroundBlackForeground:  return Colors.Constants.white50Percent
            
        }
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .blackBackgroundWhiteForeground:  return Colors.Constants.white50Percent
            
        case .whiteBackgroundBlackForeground:  return NSColor.darkGray
            
        }
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
}

