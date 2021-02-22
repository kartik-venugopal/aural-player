import Cocoa

/*
    Enumeration of all system-defined font sets.
 */
enum FontSetPreset: String, CaseIterable {
    
    // A dark scheme with a black background (the default scheme) and lighter foreground elements.
    case standard
    
    // A light scheme with an off-white background and dark foreground elements.
    case programmer
    
    // A light scheme with an off-white background and dark foreground elements.
    case futuristic

    // A dark scheme with a black background and aqua coloring of active sliders.
    case novelist

    // A semi-dark scheme with a gray background and lighter foreground elements.
    case gothic
    
    // The preset to be used as the default system scheme (eg. when a user loads the app for the very first time)
    // or when some color values in a scheme are missing.
    static var defaultSet: FontSetPreset {standard}
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> FontSetPreset? {
        
        switch name {
            
        case FontSetPreset.standard.name:    return .standard
            
        case FontSetPreset.programmer.name:    return .programmer
            
        case FontSetPreset.futuristic.name:    return .futuristic
            
        case FontSetPreset.novelist.name:    return .novelist
            
        case FontSetPreset.gothic.name:    return .gothic
            
        default:    return nil
            
        }
    }
    
    // Returns a user-friendly display name for this preset.
    var name: String {
        
        switch self {
            
        case .standard:  return "Standard"
            
        case .programmer:  return "Programmer"
            
        case .futuristic:   return "Futuristic"
            
        case .novelist:    return "Novelist"
            
        case .gothic:    return "Gothic"
            
        }
    }
    
    var infoBoxTitleFont: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_15
            
        case .programmer:  return Fonts.Programmer.mainFont_13
            
        case .futuristic:   return Fonts.Futuristic.mainFont_19
            
        case .novelist:  return Fonts.Novelist.mainFont_15
            
        case .gothic:    return Fonts.Gothic.mainFont_13
            
        }
    }
    
    var infoBoxArtistAlbumFont: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_13
            
        case .programmer:  return Fonts.Programmer.mainFont_12
            
        case .futuristic:   return Fonts.Futuristic.mainFont_16_5
            
        case .novelist:  return Fonts.Novelist.mainFont_13
            
        case .gothic:    return Fonts.Gothic.mainFont_11
            
        }
    }
    
    var infoBoxChapterTitleFont: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_11
            
        case .programmer:  return Fonts.Programmer.mainFont_11
            
        case .futuristic:   return Fonts.Futuristic.mainFont_14_5
            
        case .novelist:  return Fonts.Novelist.mainFont_11
            
        case .gothic:    return Fonts.Gothic.mainFont_10
            
        }
    }
   
    var trackTimesFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11
                
            case .programmer:  return Fonts.Programmer.mainFont_11
                
            case .futuristic:   return Fonts.Futuristic.mainFont_13_5
                
            case .novelist:  return Fonts.Novelist.mainFont_12
                
            case .gothic:    return Fonts.Gothic.mainFont_11
        }
    }
    
    var feedbackFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_9
                
            case .programmer:  return Fonts.Programmer.mainFont_8
                
            case .futuristic:   return Fonts.Futuristic.mainFont_11_5
                
            case .novelist:  return Fonts.Novelist.mainFont_10
                
            case .gothic:    return Fonts.Gothic.mainFont_8
        }
    }
    
    var playlistTrackTextFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .programmer:  return Fonts.Programmer.mainFont_11
                
            case .futuristic:   return Fonts.Futuristic.mainFont_15_5
                
            case .novelist:  return Fonts.Novelist.mainFont_13
                
            case .gothic:    return Fonts.Gothic.mainFont_11
                
        }
    }
    
    var playlistTrackTextYOffset: CGFloat {
        
        switch self {
                
            case .standard:  return -1
                
            case .programmer:  return 0
                
            case .futuristic:   return -2
                
            case .novelist:  return 0
                
            case .gothic:    return 0
                
        }
    }
    
    var playlistGroupTextFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12_5
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .futuristic:   return Fonts.Futuristic.mainFont_16_5
                
            case .novelist:  return Fonts.Novelist.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var playlistGroupTextYOffset: CGFloat {
        
        switch self {
                
            case .standard:  return -1
                
            case .programmer:  return 0
                
            case .futuristic:   return -1
                
            case .novelist:  return 0
                
            case .gothic:    return 0
                
        }
    }
    
    var playlistSummaryFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .futuristic:   return Fonts.Futuristic.mainFont_16_5
                
            case .novelist:  return Fonts.Novelist.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var playlistTabButtonTextFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_14
                
            case .programmer:  return Fonts.Programmer.captionFont_13
                
            case .futuristic:   return Fonts.Futuristic.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_14
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
        }
    }
    
    var chaptersListHeaderFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_15
                
            case .programmer:  return Fonts.Programmer.captionFont_15
                
            case .futuristic:   return Fonts.Futuristic.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_14
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
        }
    }
    
    var chaptersListSearchFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .futuristic:   return Fonts.Futuristic.mainFont_15_5
                
            case .novelist:  return Fonts.Novelist.mainFont_13
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var chaptersListCaptionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_16
                
            case .futuristic:   return Fonts.Futuristic.captionFont_18
                
            case .novelist:  return Fonts.Novelist.captionFont_18
                
            case .gothic:    return Fonts.Gothic.captionFont_15
                
        }
    }
    
    var effectsUnitCaptionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_15
                
            case .futuristic:   return Fonts.Futuristic.captionFont_19
                
            case .novelist:  return Fonts.Novelist.captionFont_15
                
            case .gothic:    return Fonts.Gothic.captionFont_16
                
        }
    }
    
    var effectsUnitFunctionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11
                
            case .programmer:  return Fonts.Programmer.mainFont_10_5
                
            case .futuristic:   return Fonts.Futuristic.mainFont_14
                
            case .novelist:  return Fonts.Novelist.mainFont_12
                
            case .gothic:    return Fonts.Gothic.mainFont_10_5
                
        }
    }
    
    var effectsMasterUnitFunctionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_13
                
            case .programmer:  return Fonts.Programmer.captionFont_11
                
            case .futuristic:   return Fonts.Futuristic.captionFont_14_5
                
            case .novelist:  return Fonts.Novelist.captionFont_12
                
            case .gothic:    return Fonts.Gothic.captionFont_13
        }
    }
    
    var effectsFilterChartFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_9
                
            case .programmer:  return Fonts.Programmer.mainFont_9
                
            case .futuristic:   return Fonts.Futuristic.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_10
                
            case .gothic:    return Fonts.Gothic.mainFont_9
        }
    }
}
