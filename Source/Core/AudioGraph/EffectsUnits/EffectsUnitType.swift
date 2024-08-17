//
//  EffectsUnitType.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AppKit

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
    case replayGain
    case au
    case devices
    
    var caption: String {
        
        switch self {
        
        case .master:   return "Master"
            
        case .eq:       return "Equalizer"
            
        case .pitch:    return "Pitch  Shift"
            
        case .time:     return "Time  Stretch"
            
        case .reverb:   return "Reverb"
            
        case .delay:    return "Delay"
            
        case .filter:   return "Filter"
            
        case .replayGain:   return "Replay  Gain"
            
        case .au:       return "Audio  Units"
            
        case .devices:  return "Output  Devices"

        }
    }
    
    var icon: NSImage {

        switch self {
        
        case .master:   return .imgMasterUnit
            
        case .eq:       return .imgEQUnit
            
        case .pitch:    return .imgPitchShiftUnit
            
        case .time:     return .imgTimeStretchUnit
            
        case .reverb:   return .imgReverbUnit
            
        case .delay:    return .imgDelayUnit
            
        case .filter:   return .imgFilterUnit
            
        case .replayGain:   return .imgReplayGainUnit

        case .au:       return .imgAudioUnit
            
        default:
            
            return .imgMasterUnit
        }
    }
}
