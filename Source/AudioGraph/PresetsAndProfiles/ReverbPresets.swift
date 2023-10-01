//
//  ReverbPresets.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Reverb effects unit.
///
class ReverbPresets: EffectsUnitPresets<ReverbPreset> {
    
    init(persistentState: ReverbUnitPersistentState?) {
        
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {ReverbPreset(persistentState: $0)}
        super.init(systemDefinedObjects: [], userDefinedObjects: userDefinedPresets)
    }
}

///
/// Represents a single Reverb effects unit preset.
///
class ReverbPreset: EffectsUnitPreset {
    
    let space: ReverbSpace
    let amount: Float
    
    init(name: String, state: EffectsUnitState, space: ReverbSpace, amount: Float, systemDefined: Bool) {
        
        self.space = space
        self.amount = amount
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: ReverbPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let space = persistentState.space,
              let amount = persistentState.amount else {return nil}
        
        self.space = space
        self.amount = amount
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
    
    func equalToOtherPreset(space: ReverbSpace, amount: Float) -> Bool {
        self.space == space && Float.valuesEqual(self.amount, amount, tolerance: 0.001) 
    }
}
