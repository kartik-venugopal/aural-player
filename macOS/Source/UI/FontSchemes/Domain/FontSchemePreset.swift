//
//  FontSchemePreset.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    static let defaultScheme: FontSchemePreset = .standard
    
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
    
//    var primaryFont: NSFont {
//        
//        switch self {
//            
//        case .standard:  return standardFontSet.mainFont(size: 14)
//            
//        case .rounded:  return roundedFontSet.mainFont(size: 16)
//            
//        case .programmer:  return programmerFontSet.mainFont(size: 14)
//            
//        case .futuristic:   return futuristicFontSet.mainFont(size: 18)
//            
//        case .novelist:  return novelistFontSet.mainFont(size: 15)
//            
//        case .soySauce:     return soySauceFontSet.mainFont(size: 25)
//            
//        case .gothic:    return gothicFontSet.mainFont(size: 14)
//            
//        case .papyrus:      return papyrusFontSet.mainFont(size: 16.5)
//            
//        case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 14)
//            
//        }
//    }
//    
//    var secondaryFont: NSFont {
//        
//        switch self {
//            
//        case .standard:  return standardFontSet.mainFont(size: 12)
//            
//        case .rounded:  return roundedFontSet.mainFont(size: 14)
//            
//        case .programmer:  return programmerFontSet.mainFont(size: 12)
//            
//        case .futuristic:   return futuristicFontSet.mainFont(size: 15.5)
//            
//        case .novelist:  return novelistFontSet.mainFont(size: 13)
//            
//        case .soySauce:     return soySauceFontSet.mainFont(size: 22)
//            
//        case .gothic:    return gothicFontSet.mainFont(size: 12)
//            
//        case .papyrus:      return papyrusFontSet.mainFont(size: 15)
//            
//        case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12)
//            
//        }
//    }
//    
//    var tertiaryFont: NSFont {
//        
//        switch self {
//            
//        case .standard:  return standardFontSet.mainFont(size: 11)
//            
//        case .rounded:  return roundedFontSet.mainFont(size: 12)
//            
//        case .programmer:  return programmerFontSet.mainFont(size: 10)
//            
//        case .futuristic:   return futuristicFontSet.mainFont(size: 14)
//            
//        case .novelist:  return novelistFontSet.mainFont(size: 11)
//            
//        case .soySauce:     return soySauceFontSet.mainFont(size: 18)
//            
//        case .gothic:    return gothicFontSet.mainFont(size: 10)
//            
//        case .papyrus:      return papyrusFontSet.mainFont(size: 13)
//            
//        case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 10)
//            
//        }
//    }
//    
//    var normalFont: NSFont {
//        
//        switch self {
//            
//        case .standard:  return standardFontSet.mainFont(size: 12)
//            
//        case .rounded:  return roundedFontSet.mainFont(size: 13)
//            
//        case .programmer:  return programmerFontSet.mainFont(size: 12)
//            
//        case .futuristic:   return futuristicFontSet.mainFont(size: 14.5)
//            
//        case .novelist:  return novelistFontSet.mainFont(size: 12.5)
//            
//        case .soySauce:     return soySauceFontSet.mainFont(size: 20)
//            
//        case .gothic:    return gothicFontSet.mainFont(size: 11.5)
//            
//        case .papyrus:      return papyrusFontSet.mainFont(size: 13.5)
//            
//        case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12)
//            
//        }
//    }
//    
//    var normalFont: NSFont {
//        
//        switch self {
//            
//        case .standard:  return standardFontSet.mainFont(size: 12)
//            
//        case .rounded:  return roundedFontSet.mainFont(size: 13)
//            
//        case .programmer:  return programmerFontSet.mainFont(size: 12)
//            
//        case .futuristic:   return futuristicFontSet.mainFont(size: 14.5)
//            
//        case .novelist:  return novelistFontSet.mainFont(size: 12.5)
//            
//        case .soySauce:     return soySauceFontSet.mainFont(size: 20)
//            
//        case .gothic:    return gothicFontSet.mainFont(size: 11.5)
//            
//        case .papyrus:      return papyrusFontSet.mainFont(size: 13.5)
//            
//        case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12)
//            
//        }
//    }
//    
//    var trackListTertiaryFont: NSFont {
//        
//        switch self {
//            
//        case .standard:  return standardFontSet.mainFont(size: 12)
//            
//        case .rounded:  return roundedFontSet.mainFont(size: 13)
//            
//        case .programmer:  return programmerFontSet.mainFont(size: 12)
//            
//        case .futuristic:   return futuristicFontSet.mainFont(size: 14.5)
//            
//        case .novelist:  return novelistFontSet.mainFont(size: 12.5)
//            
//        case .soySauce:     return soySauceFontSet.mainFont(size: 20)
//            
//        case .gothic:    return gothicFontSet.mainFont(size: 11.5)
//            
//        case .papyrus:      return papyrusFontSet.mainFont(size: 13.5)
//            
//        case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12)
//            
//        }
//    }
//    
//    var tableYOffset: CGFloat {
//        
//        switch self {
//                
//            case .standard:  return -1
//                
//            case .rounded:     return -1
//                
//            case .programmer:  return -1
//                
//            case .futuristic:   return -1
//                
//            case .novelist:  return -1
//                
//            case .soySauce:     return -2
//                
//            case .gothic:    return -1
//                
//            case .papyrus:   return 0
//                
//            case .poolsideFM:   return -1
//        }
//    }
//    
//    var playlistGroupTextFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.mainFont(size: 12.5)
//                
//            case .rounded:  return roundedFontSet.mainFont(size: 14)
//                
//            case .programmer:  return programmerFontSet.mainFont(size: 12.5)
//                
//            case .futuristic:   return futuristicFontSet.mainFont(size: 16)
//                
//            case .novelist:  return novelistFontSet.mainFont(size: 13.5)
//                
//            case .soySauce:  return soySauceFontSet.mainFont(size: 22)
//                
//            case .gothic:    return gothicFontSet.mainFont(size: 12.5)
//                
//            case .papyrus:      return papyrusFontSet.mainFont(size: 14.5)
//                
//            case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12.5)
//                
//        }
//    }
//    
//    var playlistGroupTextYOffset: CGFloat {
//        
//        switch self {
//                
//            case .standard:  return -1
//                
//            case .rounded:  return -1
//                
//            case .programmer:  return -1
//                
//            case .futuristic:   return -1
//                
//            case .novelist:  return -1
//                
//            case .soySauce:     return -2
//                
//            case .gothic:    return -2
//                
//            case .papyrus:   return -1
//                
//            case .poolsideFM:   return 0
//        }
//    }
//    
//    var playlistSummaryFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.mainFont(size: 12.5)
//                
//            case .rounded:  return roundedFontSet.mainFont(size: 14)
//                
//            case .programmer:  return programmerFontSet.mainFont(size: 12.5)
//                
//            case .futuristic:   return futuristicFontSet.mainFont(size: 16)
//                
//            case .novelist:  return novelistFontSet.mainFont(size: 13.5)
//                
//            case .soySauce:  return soySauceFontSet.mainFont(size: 22)
//                
//            case .gothic:    return gothicFontSet.mainFont(size: 12.5)
//                
//            case .papyrus:      return papyrusFontSet.mainFont(size: 14.5)
//                
//            case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12.5)
//        }
//    }
//    
//    var playlistTabButtonTextFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.captionFont(size: 15)
//                
//            case .rounded:  return roundedFontSet.captionFont(size: 14)
//                
//            case .programmer:  return programmerFontSet.captionFont(size: 14)
//                
//            case .futuristic:   return futuristicFontSet.captionFont(size: 16)
//                
//            case .novelist:  return novelistFontSet.captionFont(size: 15)
//                
//            case .soySauce:  return soySauceFontSet.captionFont(size: 16)
//                
//            case .gothic:    return gothicFontSet.captionFont(size: 15)
//                
//            case .papyrus:      return papyrusFontSet.captionFont(size: 11)
//                
//            case .poolsideFM:   return poolsideFMFontSet.captionFont(size: 14)
//        }
//    }
//    
//    var chaptersListHeaderFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.captionFont(size: 15)
//                
//            case .rounded:  return roundedFontSet.captionFont(size: 14)
//                
//            case .programmer:  return programmerFontSet.captionFont(size: 15)
//                
//            case .futuristic:   return futuristicFontSet.captionFont(size: 15)
//                
//            case .novelist:  return novelistFontSet.captionFont(size: 14)
//                
//            case .soySauce:  return soySauceFontSet.captionFont(size: 15)
//                
//            case .gothic:    return gothicFontSet.captionFont(size: 14)
//                
//            case .papyrus:      return papyrusFontSet.captionFont(size: 10)
//                
//            case .poolsideFM:   return poolsideFMFontSet.captionFont(size: 13.5)
//        }
//    }
//    
//    var chaptersListSearchFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.mainFont(size: 12)
//                
//            case .rounded:  return roundedFontSet.mainFont(size: 13)
//                
//            case .programmer:  return programmerFontSet.mainFont(size: 12)
//                
//            case .futuristic:   return futuristicFontSet.mainFont(size: 15.5)
//                
//            case .novelist:  return novelistFontSet.mainFont(size: 12.5)
//                
//            case .soySauce:  return soySauceFontSet.mainFont(size: 20)
//                
//            case .gothic:    return gothicFontSet.mainFont(size: 11.5)
//                
//            case .papyrus:      return papyrusFontSet.mainFont(size: 13.5)
//                
//            case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 12)
//        }
//    }
//    
//    var chaptersListCaptionFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.captionFont(size: 16)
//                
//            case .rounded:  return roundedFontSet.captionFont(size: 15)
//                
//            case .programmer:  return programmerFontSet.captionFont(size: 16)
//                
//            case .futuristic:   return futuristicFontSet.captionFont(size: 18)
//                
//            case .novelist:  return novelistFontSet.captionFont(size: 18)
//                
//            case .soySauce:  return soySauceFontSet.captionFont(size: 18)
//                
//            case .gothic:    return gothicFontSet.captionFont(size: 17)
//                
//            case .papyrus:   return papyrusFontSet.captionFont(size: 12)
//                
//            case .poolsideFM:   return poolsideFMFontSet.captionFont(size: 16)
//        }
//    }
//    
//    var captionFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.captionFont(size: 14)
//                
//            case .rounded:  return roundedFontSet.captionFont(size: 14)
//                
//            case .programmer:  return programmerFontSet.captionFont(size: 14)
//                
//            case .futuristic:   return futuristicFontSet.captionFont(size: 16)
//                
//            case .novelist:  return novelistFontSet.captionFont(size: 14)
//                
//            case .soySauce:  return soySauceFontSet.captionFont(size: 15)
//                
//            case .gothic:    return gothicFontSet.captionFont(size: 15)
//                
//            case .papyrus:      return papyrusFontSet.captionFont(size: 11)
//                
//            case .poolsideFM:   return poolsideFMFontSet.captionFont(size: 14)
//        }
//    }
//    
//    var normalFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.mainFont(size: 11)
//                
//            case .rounded:  return roundedFontSet.mainFont(size: 12.5)
//                
//            case .programmer:  return programmerFontSet.mainFont(size: 11)
//                
//            case .futuristic:   return futuristicFontSet.mainFont(size: 14)
//                
//            case .novelist:  return novelistFontSet.mainFont(size: 11.5)
//                
//            case .soySauce:  return soySauceFontSet.mainFont(size: 18)
//                
//            case .gothic:    return gothicFontSet.mainFont(size: 11)
//                
//            case .papyrus:      return papyrusFontSet.mainFont(size: 12)
//                
//            case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 11)
//        }
//    }
//    
//    var effectsSecondaryFont: NSFont {
//        
//        switch self {
//                
//            case .standard:  return standardFontSet.mainFont(size: 9)
//                
//            case .rounded:  return roundedFontSet.mainFont(size: 10)
//                
//            case .programmer:  return programmerFontSet.mainFont(size: 9)
//                
//            case .futuristic:   return futuristicFontSet.mainFont(size: 12)
//                
//            case .novelist:  return novelistFontSet.mainFont(size: 11)
//                
//            case .soySauce:  return soySauceFontSet.mainFont(size: 14)
//                
//            case .gothic:    return gothicFontSet.mainFont(size: 9)
//                
//            case .papyrus:      return papyrusFontSet.mainFont(size: 9)
//                
//            case .poolsideFM:   return poolsideFMFontSet.mainFont(size: 9)
//        }
//    }
//    
//    var effectsAURowTextYOffset: CGFloat {
//        
//        switch self {
//                
//            case .standard:  return 1
//                
//            case .rounded:     return 0
//                
//            case .programmer:  return 4
//                
//            case .futuristic:   return 1
//                
//            case .novelist:  return -1
//                
//            case .soySauce:     return -1
//                
//            case .gothic:    return 2
//                
//            case .papyrus:   return 1
//                
//            case .poolsideFM:   return 5
//        }
//    }
}
