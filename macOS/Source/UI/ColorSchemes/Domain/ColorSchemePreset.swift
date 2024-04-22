//
//  ColorSchemePreset.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Enumeration of all system-defined color schemes and all their color values.
 */
enum ColorSchemePreset: String, CaseIterable {
    
    // A dark scheme with a black background (the default scheme) and lighter foreground elements.
    case blackAndGreen
    
    // A light scheme with an off-white background and dark foreground elements.
    case whiteBlight
    
    // A dark scheme with a black background and aqua coloring of active sliders.
    case blackAndAqua
    
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
    static let defaultScheme: ColorSchemePreset = .lava
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> ColorSchemePreset? {
        
        switch name {
            
        case ColorSchemePreset.blackAndGreen.name:    return .blackAndGreen
            
        case ColorSchemePreset.blackAndAqua.name:    return .blackAndAqua
            
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
            
        case .blackAndGreen:  return "Black & green"
            
        case .blackAndAqua:    return "Black & aqua"
            
        case .lava:         return "Lava"
            
        case .whiteBlight:  return "White blight"
            
        case .gloomyDay:    return "Gloomy day"
            
        case .brownie:         return "Brownie"
            
        case .theBlues:     return "The blues"
            
        case .poolsideFM:     return "Poolside.fm"
            
        }
    }
}
