//
//  TimeStretchPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Time Stretch effects unit.
///
class TimeStretchPresets: EffectsPresets<TimeStretchPreset> {
    
    init(persistentState: TimeStretchUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedTimeStretchPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {TimeStretchPreset(persistentState: $0)}
        
        super.init(systemDefinedPresets: systemDefinedPresets, userDefinedPresets: userDefinedPresets)
    }
    
    override var defaultPreset: TimeStretchPreset {systemDefinedPreset(named: SystemDefinedTimeStretchPresetParams.normal.rawValue)!}
}

///
/// Represents a single Time Stretch effects unit preset.
///
class TimeStretchPreset: EffectsUnitPreset {
    
    let rate: Float
    let overlap: Float
    let shiftPitch: Bool
    
    init(_ name: String, _ state: EffectsUnitState, _ rate: Float, _ overlap: Float, _ shiftPitch: Bool, _ systemDefined: Bool) {
        
        self.rate = rate
        self.overlap = overlap
        self.shiftPitch = shiftPitch
        super.init(name, state, systemDefined)
    }
    
    init?(persistentState: TimeStretchPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let rate = persistentState.rate else {return nil}
        
        self.rate = rate
        self.overlap = persistentState.overlap ?? AudioGraphDefaults.timeOverlap
        self.shiftPitch = persistentState.shiftPitch ?? AudioGraphDefaults.timeShiftPitch
        
        super.init(name, unitState, false)
    }
}

///
/// An enumeration of system-defined (built-in) Time Stretch presets the user can choose from.
///
fileprivate enum SystemDefinedTimeStretchPresetParams: String, CaseIterable {
    
    case normal = "Normal (1x)"  // default
    
    case quarterX = "0.25x"
    case halfX = "0.5x"
    case threeFourthsX = "0.75x"
    
    case twoX = "2x"
    case threeX = "3x"
    case fourX = "4x"
    
    case tooMuchCoffee = "Too much coffee"
    case laidBack = "Laid back"
    case speedyGonzales = "Speedy Gonzales"
    case slowLikeMolasses = "Slow like molasses"
    
    // Converts a user-friendly display name to an instance of TimeStretchPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedTimeStretchPresetParams {
        return SystemDefinedTimeStretchPresetParams(rawValue: displayName) ?? .normal
    }
    
    var rate: Float {
        
        switch self {
            
        case .normal:   return 1
            
        case .quarterX: return 0.25
            
        case .halfX: return 0.5
            
        case .threeFourthsX:  return 0.75
            
        case .twoX: return 2
            
        case .threeX: return 3
            
        case .fourX:  return 4
            
        case .tooMuchCoffee:    return 1.15
            
        case .laidBack:   return 0.9
            
        case .speedyGonzales:   return 1.5
            
        case .slowLikeMolasses: return 0.8
            
        }
    }
    
    var overlap: Float {
        return 8
    }
    
    var shiftPitch: Bool {
        return true
    }
    
    var state: EffectsUnitState {
        return .active
    }
    
    var preset: TimeStretchPreset {
        TimeStretchPreset(rawValue, state, rate, overlap, shiftPitch, true)
    }
}
