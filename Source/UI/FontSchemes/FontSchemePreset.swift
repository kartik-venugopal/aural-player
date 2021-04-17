import Cocoa

/*
    Enumeration of all system-defined font schemes.
 */
enum FontSchemePreset: String, CaseIterable {
    
    case standard
    
    case rounded
    
    case programmer
    
    case futuristic

    case novelist
    
    // Chinese-style font
    case soySauce

    case gothic
    
    case papyrus
    
    case poolsideFM
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> FontSchemePreset? {
        
        switch name {
            
        case FontSchemePreset.standard.name:    return .standard
            
        case FontSchemePreset.rounded.name:     return .rounded
            
        case FontSchemePreset.programmer.name:    return .programmer
            
        case FontSchemePreset.futuristic.name:    return .futuristic
            
        case FontSchemePreset.novelist.name:    return .novelist
            
        case FontSchemePreset.soySauce.name:    return .soySauce
            
        case FontSchemePreset.gothic.name:    return .gothic
            
        case FontSchemePreset.papyrus.name:     return .papyrus
            
        case FontSchemePreset.poolsideFM.name:     return .poolsideFM
            
        default:    return nil
            
        }
    }
    
    // Returns a user-friendly display name for this preset.
    var name: String {
        
        switch self {
            
        case .standard:  return "Standard"
            
        case .rounded:  return "Rounded"
            
        case .programmer:  return "Programmer"
            
        case .futuristic:   return "Futuristic"
            
        case .novelist:    return "Novelist"
            
        case .soySauce:     return "Soy Sauce"
            
        case .gothic:    return "Gothic"
            
        case .papyrus:   return "Papyrus"
            
        case .poolsideFM:   return "Poolside.fm"
            
        }
    }
    
    var infoBoxTitleFont: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_15
            
        case .rounded:  return Fonts.Rounded.mainFont_16
            
        case .programmer:  return Fonts.Programmer.mainFont_14
            
        case .futuristic:   return Fonts.Futuristic.mainFont_19
            
        case .novelist:  return Fonts.Novelist.mainFont_15
            
        case .soySauce:     return Fonts.SoySauce.mainFont_25
            
        case .gothic:    return Fonts.Gothic.mainFont_14
            
        case .papyrus:      return Fonts.Papyrus.mainFont_16_5
            
        case .poolsideFM:   return Fonts.PoolsideFM.mainFont_14
            
        }
    }
    
    var infoBoxArtistAlbumFont: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_13
            
        case .rounded:  return Fonts.Rounded.mainFont_14
            
        case .programmer:  return Fonts.Programmer.mainFont_12
            
        case .futuristic:   return Fonts.Futuristic.mainFont_16_5
            
        case .novelist:  return Fonts.Novelist.mainFont_13
            
        case .soySauce:     return Fonts.SoySauce.mainFont_22
            
        case .gothic:    return Fonts.Gothic.mainFont_12
            
        case .papyrus:      return Fonts.Papyrus.mainFont_15
            
        case .poolsideFM:   return Fonts.PoolsideFM.mainFont_12
            
        }
    }
    
    var infoBoxChapterTitleFont: NSFont {
        
        switch self {
            
        case .standard:  return Fonts.Standard.mainFont_11
            
        case .rounded:  return Fonts.Rounded.mainFont_12
            
        case .programmer:  return Fonts.Programmer.mainFont_10
            
        case .futuristic:   return Fonts.Futuristic.mainFont_14_5
            
        case .novelist:  return Fonts.Novelist.mainFont_11
            
        case .soySauce:     return Fonts.SoySauce.mainFont_18
            
        case .gothic:    return Fonts.Gothic.mainFont_10
            
        case .papyrus:      return Fonts.Papyrus.mainFont_13
            
        case .poolsideFM:   return Fonts.PoolsideFM.mainFont_10
            
        }
    }
   
    var trackTimesFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11
                
            case .rounded:  return Fonts.Rounded.mainFont_12
                
            case .programmer:  return Fonts.Programmer.mainFont_11
                
            case .futuristic:   return Fonts.Futuristic.mainFont_13_5
                
            case .novelist:  return Fonts.Novelist.mainFont_12
                
            case .soySauce:     return Fonts.SoySauce.mainFont_17
                
            case .gothic:    return Fonts.Gothic.mainFont_11
                
            case .papyrus:      return Fonts.Papyrus.mainFont_13
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_11
        }
    }
    
    var feedbackFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_9
                
            case .rounded:  return Fonts.Rounded.mainFont_10_5
                
            case .programmer:  return Fonts.Programmer.mainFont_9
                
            case .futuristic:   return Fonts.Futuristic.mainFont_11
                
            case .novelist:  return Fonts.Novelist.mainFont_9
                
            case .soySauce:     return Fonts.SoySauce.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_9
                
            case .papyrus:      return Fonts.Papyrus.mainFont_11
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_9
        }
    }
    
    var playlistTrackTextFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .rounded:  return Fonts.Rounded.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .futuristic:   return Fonts.Futuristic.mainFont_15_5
                
            case .novelist:  return Fonts.Novelist.mainFont_12_5
                
            case .soySauce:     return Fonts.SoySauce.mainFont_20
                
            case .gothic:    return Fonts.Gothic.mainFont_11_5
                
            case .papyrus:      return Fonts.Papyrus.mainFont_13_5
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_12
        }
    }
    
    var playlistTrackTextYOffset: CGFloat {
        
        switch self {
                
            case .standard:  return -1
                
            case .rounded:     return -1
                
            case .programmer:  return -1
                
            case .futuristic:   return -2
                
            case .novelist:  return -1
                
            case .soySauce:     return -2
                
            case .gothic:    return -1
                
            case .papyrus:   return 0
                
            case .poolsideFM:   return -1
        }
    }
    
    var playlistGroupTextFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12_5
                
            case .rounded:  return Fonts.Rounded.mainFont_14
                
            case .programmer:  return Fonts.Programmer.mainFont_12_5
                
            case .futuristic:   return Fonts.Futuristic.mainFont_16
                
            case .novelist:  return Fonts.Novelist.mainFont_13_5
                
            case .soySauce:  return Fonts.SoySauce.mainFont_22
                
            case .gothic:    return Fonts.Gothic.mainFont_12_5
                
            case .papyrus:      return Fonts.Papyrus.mainFont_14_5
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_12_5
                
        }
    }
    
    var playlistGroupTextYOffset: CGFloat {
        
        switch self {
                
            case .standard:  return -1
                
            case .rounded:  return -1
                
            case .programmer:  return -1
                
            case .futuristic:   return -1
                
            case .novelist:  return -1
                
            case .soySauce:     return -2
                
            case .gothic:    return -2
                
            case .papyrus:   return -1
                
            case .poolsideFM:   return 0
        }
    }
    
    var playlistSummaryFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12_5
                
            case .rounded:  return Fonts.Rounded.mainFont_14
                
            case .programmer:  return Fonts.Programmer.mainFont_12_5
                
            case .futuristic:   return Fonts.Futuristic.mainFont_16
                
            case .novelist:  return Fonts.Novelist.mainFont_13_5
                
            case .soySauce:  return Fonts.SoySauce.mainFont_22
                
            case .gothic:    return Fonts.Gothic.mainFont_12_5
                
            case .papyrus:      return Fonts.Papyrus.mainFont_14_5
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_12_5
        }
    }
    
    var playlistTabButtonTextFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_14
                
            case .rounded:  return Fonts.Rounded.captionFont_14
                
            case .programmer:  return Fonts.Programmer.captionFont_13
                
            case .futuristic:   return Fonts.Futuristic.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_14
                
            case .soySauce:  return Fonts.SoySauce.captionFont_15
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
            case .papyrus:      return Fonts.Papyrus.captionFont_11
                
            case .poolsideFM:   return Fonts.PoolsideFM.captionFont_13
        }
    }
    
    var chaptersListHeaderFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_15
                
            case .rounded:  return Fonts.Rounded.captionFont_14
                
            case .programmer:  return Fonts.Programmer.captionFont_15
                
            case .futuristic:   return Fonts.Futuristic.captionFont_15
                
            case .novelist:  return Fonts.Novelist.captionFont_14
                
            case .soySauce:  return Fonts.SoySauce.captionFont_15
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
            case .papyrus:      return Fonts.Papyrus.captionFont_10
                
            case .poolsideFM:   return Fonts.PoolsideFM.captionFont_13_5
        }
    }
    
    var chaptersListSearchFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_12
                
            case .rounded:  return Fonts.Rounded.mainFont_13
                
            case .programmer:  return Fonts.Programmer.mainFont_12
                
            case .futuristic:   return Fonts.Futuristic.mainFont_15_5
                
            case .novelist:  return Fonts.Novelist.mainFont_12_5
                
            case .soySauce:  return Fonts.SoySauce.mainFont_20
                
            case .gothic:    return Fonts.Gothic.mainFont_11_5
                
            case .papyrus:      return Fonts.Papyrus.mainFont_13_5
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_12
        }
    }
    
    var chaptersListCaptionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_16
                
            case .rounded:  return Fonts.Rounded.captionFont_15
                
            case .programmer:  return Fonts.Programmer.captionFont_16
                
            case .futuristic:   return Fonts.Futuristic.captionFont_18
                
            case .novelist:  return Fonts.Novelist.captionFont_18
                
            case .soySauce:  return Fonts.SoySauce.captionFont_18
                
            case .gothic:    return Fonts.Gothic.captionFont_17
                
            case .papyrus:   return Fonts.Papyrus.captionFont_12
                
            case .poolsideFM:   return Fonts.PoolsideFM.captionFont_16
        }
    }
    
    var effectsUnitCaptionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_18
                
            case .rounded:  return Fonts.Rounded.captionFont_16
                
            case .programmer:  return Fonts.Programmer.captionFont_16
                
            case .futuristic:   return Fonts.Futuristic.captionFont_19
                
            case .novelist:  return Fonts.Novelist.captionFont_15
                
            case .soySauce:  return Fonts.SoySauce.captionFont_19
                
            case .gothic:    return Fonts.Gothic.captionFont_17
                
            case .papyrus:      return Fonts.Papyrus.captionFont_12_5
                
            case .poolsideFM:   return Fonts.PoolsideFM.captionFont_16
        }
    }
    
    var effectsUnitFunctionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_11
                
            case .rounded:  return Fonts.Rounded.mainFont_12_5
                
            case .programmer:  return Fonts.Programmer.mainFont_11
                
            case .futuristic:   return Fonts.Futuristic.mainFont_14
                
            case .novelist:  return Fonts.Novelist.mainFont_11_5
                
            case .soySauce:  return Fonts.SoySauce.mainFont_18
                
            case .gothic:    return Fonts.Gothic.mainFont_11
                
            case .papyrus:      return Fonts.Papyrus.mainFont_12
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_11
        }
    }
    
    var effectsMasterUnitFunctionFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.captionFont_14
                
            case .rounded:  return Fonts.Rounded.captionFont_13_5
                
            case .programmer:  return Fonts.Programmer.captionFont_13
                
            case .futuristic:   return Fonts.Futuristic.captionFont_14
                
            case .novelist:  return Fonts.Novelist.captionFont_12_5
                
            case .soySauce:  return Fonts.SoySauce.captionFont_14
                
            case .gothic:    return Fonts.Gothic.captionFont_14
                
            case .papyrus:      return Fonts.Papyrus.captionFont_10
                
            case .poolsideFM:   return Fonts.PoolsideFM.captionFont_13
        }
    }
    
    var effectsFilterChartFont: NSFont {
        
        switch self {
                
            case .standard:  return Fonts.Standard.mainFont_9
                
            case .rounded:  return Fonts.Rounded.mainFont_10
                
            case .programmer:  return Fonts.Programmer.mainFont_9
                
            case .futuristic:   return Fonts.Futuristic.mainFont_12
                
            case .novelist:  return Fonts.Novelist.mainFont_11
                
            case .soySauce:  return Fonts.SoySauce.mainFont_14
                
            case .gothic:    return Fonts.Gothic.mainFont_9
                
            case .papyrus:      return Fonts.Papyrus.mainFont_9
                
            case .poolsideFM:   return Fonts.PoolsideFM.mainFont_9
        }
    }
    
    var effectsAURowTextYOffset: CGFloat {
        
        switch self {
                
            case .standard:  return 1
                
            case .rounded:     return 0
                
            case .programmer:  return 4
                
            case .futuristic:   return 1
                
            case .novelist:  return -1
                
            case .soySauce:     return -1
                
            case .gothic:    return 2
                
            case .papyrus:   return 1
                
            case .poolsideFM:   return 5
        }
    }
}
