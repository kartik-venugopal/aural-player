//
//  ReverbPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class ReverbPresets: EffectsPresets<ReverbPreset> {
    
    init(persistentState: ReverbUnitPersistentState?) {
        
        let userDefinedPresets = (persistentState?.userPresets ?? []).map {ReverbPreset(persistentState: $0)}
        super.init(systemDefinedPresets: [], userDefinedPresets: userDefinedPresets)
    }
}

class ReverbPreset: EffectsUnitPreset {
    
    let space: ReverbSpaces
    let amount: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ space: ReverbSpaces, _ amount: Float, _ systemDefined: Bool) {
        
        self.space = space
        self.amount = amount
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: ReverbPresetPersistentState) {
        
        self.space = persistentState.space
        self.amount = persistentState.amount
        super.init(persistentState.name, persistentState.state, false)
    }
}
