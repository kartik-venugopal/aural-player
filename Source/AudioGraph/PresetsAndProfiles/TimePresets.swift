//
//  TimePresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TimePresets: FXPresets<TimePreset> {
    
    init(persistentState: TimeUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedTimePresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).map {TimePreset(persistentState: $0)}
        
        super.init(systemDefinedPresets: systemDefinedPresets, userDefinedPresets: userDefinedPresets)
    }
    
    override var defaultPreset: TimePreset {systemDefinedPreset(named: SystemDefinedTimePresetParams.normal.rawValue)!}
}

class TimePreset: FXUnitPreset {
    
    let rate: Float
    let overlap: Float
    let shiftPitch: Bool
    
    init(_ name: String, _ state: FXUnitState, _ rate: Float, _ overlap: Float, _ shiftPitch: Bool, _ systemDefined: Bool) {
        
        self.rate = rate
        self.overlap = overlap
        self.shiftPitch = shiftPitch
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: TimePresetPersistentState) {
        
        self.rate = persistentState.rate
        self.overlap = persistentState.overlap ?? AudioGraphDefaults.timeOverlap
        self.shiftPitch = persistentState.shiftPitch ?? AudioGraphDefaults.timeShiftPitch
        
        super.init(persistentState: persistentState)
    }
}

/*
    An enumeration of built-in pitch presets the user can choose from
 */
fileprivate enum SystemDefinedTimePresetParams: String, CaseIterable {
    
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
    
    // Converts a user-friendly display name to an instance of TimePresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedTimePresetParams {
        return SystemDefinedTimePresetParams(rawValue: displayName) ?? .normal
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
    
    var state: FXUnitState {
        return .active
    }
    
    var preset: TimePreset {
        TimePreset(rawValue, state, rate, overlap, shiftPitch, true)
    }
}
