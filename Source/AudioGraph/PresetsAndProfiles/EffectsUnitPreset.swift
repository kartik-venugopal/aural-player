//
//  EffectsUnitPreset.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class EffectsUnitPreset: MappedPreset {
    
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}
    
    let systemDefined: Bool
    var state: EffectsUnitState
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool) {
        
        self.name = name
        self.state = state
        self.systemDefined = systemDefined
    }
    
    init(persistentState: EffectsUnitPresetPersistentState) {
        
        self.name = persistentState.name
        self.state = persistentState.state
        self.systemDefined = false
    }
}
