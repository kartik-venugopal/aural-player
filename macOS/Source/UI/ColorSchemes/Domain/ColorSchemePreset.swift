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

    // the default scheme
    case lava
    
    // A dark scheme with a black background and lighter foreground elements.
    case blackAndGreen
    
    // A dark scheme with a black background and aqua coloring of active sliders.
    case blackAndAqua
    
    case grayRed
    
    // A light scheme with an off-white background and dark foreground elements.
    case whiteBlight
    
    // A semi-dark scheme with a gray background and lighter foreground elements.
    case gloomyDay
    
    // A semi-dark scheme with a brown background and lighter reddish-brown foreground elements.
    case brownie
    
    case poolsideFM
    
    // The preset to be used as the default system scheme (eg. when a user loads the app for the very first time)
    // or when some color values in a scheme are missing.
    static let defaultScheme: ColorSchemePreset = .lava
    
    // Maps a display name to a preset.
    static func presetByName(_ name: String) -> ColorSchemePreset? {
        
        switch name {
            
        case ColorSchemePreset.lava.name:    return .lava
            
        case ColorSchemePreset.blackAndGreen.name:    return .blackAndGreen
            
        case ColorSchemePreset.blackAndAqua.name:    return .blackAndAqua
            
        case ColorSchemePreset.grayRed.name:   return .grayRed
            
        case ColorSchemePreset.whiteBlight.name:    return .whiteBlight
            
        case ColorSchemePreset.gloomyDay.name:      return .gloomyDay
            
        case ColorSchemePreset.brownie.name:      return .brownie
            
        case ColorSchemePreset.poolsideFM.name:   return .poolsideFM
            
        default:    return nil
            
        }
    }
    
    // Returns a user-friendly display name for this preset.
    var name: String {
        
        switch self {
            
        case .lava:         return "Lava"
            
        case .blackAndGreen:  return "Black & green"
            
        case .blackAndAqua:    return "Black & aqua"
            
        case .grayRed:     return "Gray & red"
            
        case .whiteBlight:  return "White blight"
            
        case .gloomyDay:    return "Gloomy day"
            
        case .brownie:         return "Brownie"
            
        case .poolsideFM:     return "Poolside.fm"
            
        }
    }
}
