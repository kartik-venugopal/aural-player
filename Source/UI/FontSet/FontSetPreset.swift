import Cocoa

/*
    Enumeration of all system-defined font sets.
 */
enum FontSetPreset: String, CaseIterable {
    
    // A dark scheme with a black background (the default scheme) and lighter foreground elements.
    case standard
    
    // A light scheme with an off-white background and dark foreground elements.
    case programmer

    // A dark scheme with a black background and aqua coloring of active sliders.
    case novelist

    // A semi-dark scheme with a gray background and lighter foreground elements.
    case gothic
    
    // The preset to be used as the default system scheme (eg. when a user loads the app for the very first time)
    // or when some color values in a scheme are missing.
    static var defaultSet: FontSetPreset {
        return standard
    }
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> FontSetPreset? {
        
        switch name {
            
        case FontSetPreset.standard.name:    return .standard
            
        case FontSetPreset.programmer.name:    return .programmer
            
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
            
        case .novelist:    return "Novelist"
            
        case .gothic:    return "Gothic"
            
        }
    }
    
    var infoBoxTitleFont_normal: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_15
            
        case .programmer:  return Fonts.Programmer.mainFont_13
            
        case .novelist:  return Fonts.Novelist.mainFont_16
            
        case .gothic:    return Fonts.Gothic.mainFont_13
            
        }
    }
    
    var infoBoxTitleFont_larger: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_17
            
        case .programmer:  return Fonts.Programmer.mainFont_15
            
        case .novelist:  return Fonts.Novelist.mainFont_18
            
        case .gothic:    return Fonts.Gothic.mainFont_15
            
        }
    }
    
    var infoBoxTitleFont_largest: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_19
            
        case .programmer:  return Fonts.Programmer.mainFont_17
            
        case .novelist:  return Fonts.Novelist.mainFont_20
            
        case .gothic:    return Fonts.Gothic.mainFont_17
            
        }
    }
    
    var infoBoxArtistAlbumFont_normal: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_13
            
        case .programmer:  return Fonts.Programmer.mainFont_12
            
        case .novelist:  return Fonts.Novelist.mainFont_14
            
        case .gothic:    return Fonts.Gothic.mainFont_11
            
        }
    }
    
    var infoBoxArtistAlbumFont_larger: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_15
            
        case .programmer:  return Fonts.Programmer.mainFont_14
            
        case .novelist:  return Fonts.Novelist.mainFont_16
            
        case .gothic:    return Fonts.Gothic.mainFont_13
            
        }
    }
    
    var infoBoxArtistAlbumFont_largest: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_17
            
        case .programmer:  return Fonts.Programmer.mainFont_16
            
        case .novelist:  return Fonts.Novelist.mainFont_18
            
        case .gothic:    return Fonts.Gothic.mainFont_15
            
        }
    }
    
    var infoBoxChapterFont_normal: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_11
            
        case .programmer:  return Fonts.Programmer.mainFont_11
            
        case .novelist:  return Fonts.Novelist.mainFont_12
            
        case .gothic:    return Fonts.Gothic.mainFont_10
            
        }
    }
    
    var infoBoxChapterFont_larger: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_12
            
        case .programmer:  return Fonts.Programmer.mainFont_12
            
        case .novelist:  return Fonts.Novelist.mainFont_13_5
            
        case .gothic:    return Fonts.Gothic.mainFont_11
            
        }
    }
    
    var infoBoxChapterFont_largest: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_13
            
        case .programmer:  return Fonts.Programmer.mainFont_13
            
        case .novelist:  return Fonts.Novelist.mainFont_15
            
        case .gothic:    return Fonts.Gothic.mainFont_12
            
        }
    }
    
    var trackTimesFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11
                
            case .programmer:  return Fonts.Programmer.mainFont_11
                
            case .novelist:  return Fonts.Novelist.mainFont_12
                
            case .gothic:    return Fonts.Gothic.mainFont_11
        }
    }
    
    var trackTimesFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_13_5
                
            case .gothic:    return Fonts.Gothic.mainFont_12
        }
    }
    
    var trackTimesFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_13
                
            case .novelist:  return Fonts.Novelist.mainFont_15
                
            case .gothic:    return Fonts.Gothic.mainFont_13
        }
    }
    
    var feedbackFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_9
                
            case .programmer:  return Fonts.Programmer.mainFont_8
                
            case .novelist:  return Fonts.Novelist.mainFont_9
                
            case .gothic:    return Fonts.Gothic.mainFont_8
        }
    }
    
    var feedbackFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_10
                
            case .programmer:  return Fonts.Programmer.mainFont_9
                
            case .novelist:  return Fonts.Novelist.mainFont_10_5
                
            case .gothic:    return Fonts.Gothic.mainFont_9
        }
    }
    
    var feedbackFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11
                
            case .programmer:  return Fonts.Programmer.mainFont_10
                
            case .novelist:  return Fonts.Novelist.mainFont_12
                
            case .gothic:    return Fonts.Gothic.mainFont_10
        }
    }
    
    var playlistTrackTextFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .programmer:  return Fonts.Programmer.mainFont_11
                
            case .novelist:  return Fonts.Novelist.mainFont_13
                
            case .gothic:    return Fonts.Gothic.mainFont_11
                
        }
    }
    
    var playlistTrackTextFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var playlistTrackTextFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_14
                
            case .programmer:  return Fonts.Programmer.mainFont_13
                
            case .novelist:  return Fonts.Novelist.mainFont_15
                
            case .gothic:    return Fonts.Gothic.mainFont_13
                
        }
    }
    
    var playlistGroupTextFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12_5
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var playlistGroupTextFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_13_5
                
            case .programmer:  return Fonts.Programmer.mainFont_13
                
            case .novelist:  return Fonts.Novelist.mainFont_15
                
            case .gothic:    return Fonts.Gothic.mainFont_13
                
        }
    }
    
    var playlistGroupTextFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_14_5
                
            case .programmer:  return Fonts.Programmer.mainFont_14
                
            case .novelist:  return Fonts.Novelist.mainFont_16
                
            case .gothic:    return Fonts.Gothic.mainFont_14
                
        }
    }
    
    var playlistSummaryFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var playlistSummaryFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_14
                
            case .programmer:  return Fonts.Programmer.mainFont_13
                
            case .novelist:  return Fonts.Novelist.mainFont_15
                
            case .gothic:    return Fonts.Gothic.mainFont_13
                
        }
    }
    
    var playlistSummaryFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_15
                
            case .programmer:  return Fonts.Programmer.mainFont_14
                
            case .novelist:  return Fonts.Novelist.mainFont_16
                
            case .gothic:    return Fonts.Gothic.mainFont_14
                
        }
    }
    
    var playlistTabButtonTextFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_14
                
            case .programmer:  return Fonts.Programmer.captionFont_13
                
            case .novelist:  return Fonts.Novelist.captionFont_14
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
        }
    }
    
    var playlistTabButtonTextFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_15
                
            case .programmer:  return Fonts.Programmer.captionFont_14
                
            case .novelist:  return Fonts.Novelist.captionFont_15
                
            case .gothic:    return Fonts.Gothic.captionFont_15
                
        }
    }
    
    var playlistTabButtonTextFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_16
                
            case .gothic:    return Fonts.Gothic.captionFont_16
                
        }
    }
    
    var chaptersListHeaderFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_15
                
            case .programmer:  return Fonts.Programmer.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_16
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
        }
    }
    
    var chaptersListHeaderFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_16
                
            case .novelist:  return Fonts.Novelist.captionFont_17
                
            case .gothic:    return Fonts.Gothic.captionFont_15
                
        }
    }
    
    var chaptersListHeaderFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_17
                
            case .programmer:  return Fonts.Programmer.captionFont_17
                
            case .novelist:  return Fonts.Novelist.captionFont_18
                
            case .gothic:    return Fonts.Gothic.captionFont_16
                
        }
    }
    
    var chaptersListSearchFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_12
                
        }
    }
    
    var chaptersListSearchFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_13
                
            case .novelist:  return Fonts.Novelist.mainFont_15
                
            case .gothic:    return Fonts.Gothic.mainFont_13
                
        }
    }
    
    var chaptersListSearchFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_14
                
            case .programmer:  return Fonts.Programmer.mainFont_14
                
            case .novelist:  return Fonts.Novelist.mainFont_16
                
            case .gothic:    return Fonts.Gothic.mainFont_14
                
        }
    }
    
    var chaptersListCaptionFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_16
                
            case .novelist:  return Fonts.Novelist.captionFont_18
                
            case .gothic:    return Fonts.Gothic.captionFont_15
                
        }
    }
    
    var chaptersListCaptionFont_larger: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_17
                
            case .programmer:  return Fonts.Programmer.captionFont_17
                
            case .novelist:  return Fonts.Novelist.captionFont_19
                
            case .gothic:    return Fonts.Gothic.captionFont_16
                
        }
    }
    
    var chaptersListCaptionFont_largest: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_18
                
            case .programmer:  return Fonts.Programmer.captionFont_18
                
            case .novelist:  return Fonts.Novelist.captionFont_20
                
            case .gothic:    return Fonts.Gothic.captionFont_17
                
        }
    }
    
    var effectsUnitCaptionFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_17
                
            case .gothic:    return Fonts.Gothic.captionFont_16
                
        }
    }
    
    var effectsUnitFunctionFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11_5
                
            case .programmer:  return Fonts.Programmer.mainFont_10_5
                
            case .novelist:  return Fonts.Novelist.mainFont_11_5
                
            case .gothic:    return Fonts.Gothic.mainFont_10_5
                
        }
    }
    
    var effectsMasterUnitFunctionFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_13
                
            case .programmer:  return Fonts.Programmer.captionFont_11
                
            case .novelist:  return Fonts.Novelist.captionFont_14
                
            case .gothic:    return Fonts.Gothic.captionFont_13
                
        }
    }
    
    var effectsFilterChartFont_normal: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_9
                
            case .programmer:  return Fonts.Programmer.mainFont_9
                
            case .novelist:  return Fonts.Novelist.mainFont_9
                
            case .gothic:    return Fonts.Gothic.mainFont_9
                
        }
    }
}
