//
//  EffectsUnitType.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An enumeration of all the effects unit types.
///
enum EffectsUnitType: Int {

    case master
    case eq
    case pitch
    case time
    case reverb
    case delay
    case filter
    case au
    
    var caption: String {
        
        switch self {
            
        case .master:   return "Master"
            
        case .eq:       return "Equalizer"
            
        case .pitch:    return "Pitch  Shift"
            
        case .time:     return "Time  Stretch"
            
        case .reverb:   return "Reverb"
            
        case .delay:    return "Delay"
            
        case .filter:   return "Filter"
            
        case .au:       return "Audio  Units"
            
        }
    }
}
