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
class TimeStretchPresets: EffectsUnitPresets<TimeStretchPreset> {
    
    init(persistentState: TimeStretchUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedTimeStretchPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {TimeStretchPreset(persistentState: $0)}
        
        super.init(systemDefinedObjects: systemDefinedPresets, userDefinedObjects: userDefinedPresets)
    }
    
    override var defaultPreset: TimeStretchPreset {systemDefinedObject(named: SystemDefinedTimeStretchPresetParams.normal.rawValue)!}
}

///
/// Represents a single Time Stretch effects unit preset.
///
class TimeStretchPreset: EffectsUnitPreset {
    
    let rate: Float
    let shiftPitch: Bool
    let shiftedPitch: Float
    
    init(name: String, state: EffectsUnitState, rate: Float, shiftPitch: Bool, systemDefined: Bool) {
        
        self.rate = rate
        self.shiftPitch = shiftPitch
        
        self.shiftedPitch = shiftPitch ? 1200 * log2(rate) : 0
        
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: TimeStretchPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let rate = persistentState.rate else {return nil}
        
        self.rate = rate
        self.shiftPitch = persistentState.shiftPitch ?? AudioGraphDefaults.timeStretchShiftPitch
        
        self.shiftedPitch = shiftPitch ? 1200 * log2(rate) : 0
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
    
    func equalToOtherPreset(rate: Float, shiftPitch: Bool) -> Bool {
        Float.valuesEqual(self.rate, rate, tolerance: 0.001) && self.shiftPitch == shiftPitch
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
    
    var preset: TimeStretchPreset {
        TimeStretchPreset(name: rawValue, state: .active, rate: rate, shiftPitch: true, systemDefined: true)
    }
}
