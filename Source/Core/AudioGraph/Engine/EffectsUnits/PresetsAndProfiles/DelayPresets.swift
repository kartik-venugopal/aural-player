//
//  DelayPresets.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Delay effects unit.
///
class DelayPresets: EffectsUnitPresets<DelayPreset> {
    
    func initialize(persistentState: DelayUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedDelayPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {DelayPreset(persistentState: $0)}
        
        super.initialize(systemDefinedObjects: systemDefinedPresets, userDefinedObjects: userDefinedPresets)
    }
    
    override var defaultPreset: DelayPreset {systemDefinedObject(named: SystemDefinedDelayPresetParams.oneSecond.rawValue)!}
}

///
/// Represents a single Delay effects unit preset.
///
class DelayPreset: EffectsUnitPreset {
    
    let amount: Float
    let time: Double
    let feedback: Float
    let lowPassCutoff: Float
    
    init(name: String, state: EffectsUnitState, amount: Float, time: Double, feedback: Float, cutoff: Float, systemDefined: Bool) {
        
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = cutoff
        
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: DelayPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let amount = persistentState.amount,
              let time = persistentState.time,
              let feedback = persistentState.feedback,
              let lowPassCutoff = persistentState.lowPassCutoff else {return nil}
        
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
}

///
/// An enumeration of system-defined (built-in) Delay presets the user can choose from.
///
fileprivate enum SystemDefinedDelayPresetParams: String, CaseIterable {
    
    case quarterSecond = "1/4 second delay"
    case halfSecond = "1/2 second delay"
    case threeFourthsSecond = "3/4 second delay"
    case oneSecond = "1 second delay"   // default
    case twoSeconds = "2 seconds delay"
    
    case slightEcho = "Slight echo"
    
    // Converts a user-friendly display name to an instance of DelayPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedDelayPresetParams {
        return SystemDefinedDelayPresetParams(rawValue: displayName) ?? .oneSecond
    }
    
    var time: Double {
        
        switch self {
            
        case .quarterSecond:    return 0.25
            
        case .halfSecond:   return 0.5
            
        case .threeFourthsSecond:   return 0.75
            
        case .oneSecond:    return 1
            
        case .twoSeconds:   return 2
            
        case .slightEcho:   return 0.05
            
        }
    }
    
    var amount: Float {
        return self == .slightEcho ? 20 : 50
    }
    
    var feedback: Float {
        return self == .slightEcho ? 25 : 50
    }
    
    var preset: DelayPreset {
        DelayPreset(name: rawValue, state: .active, amount: amount, time: time, feedback: feedback, cutoff: 15000, systemDefined: true)
    }
}
