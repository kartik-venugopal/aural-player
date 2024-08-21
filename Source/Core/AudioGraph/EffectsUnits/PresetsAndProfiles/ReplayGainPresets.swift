//
//  ReplayGainPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ReplayGainPresets: EffectsUnitPresets<ReplayGainPreset> {
    
    init(persistentState: ReplayGainUnitPersistentState?) {
        
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {ReplayGainPreset(persistentState: $0)}
        super.init(systemDefinedObjects: [], userDefinedObjects: userDefinedPresets)
    }
}

class ReplayGainPreset: EffectsUnitPreset {
    
    let mode: ReplayGainMode
    let preAmp: Float
    let preventClipping: Bool
    
    init(name: String, state: EffectsUnitState, mode: ReplayGainMode, preAmp: Float, preventClipping: Bool, systemDefined: Bool) {
        
        self.mode = mode
        self.preAmp = preAmp
        self.preventClipping = preventClipping
        
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: ReplayGainPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let mode = persistentState.mode,
              let preAmp = persistentState.preAmp else {return nil}
        
        self.mode = mode
        self.preAmp = preAmp
        self.preventClipping = persistentState.preventClipping ?? AudioGraphDefaults.replayGainPreventClipping
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
    
    func equalToOtherPreset(mode: ReplayGainMode, preAmp: Float, preventClipping: Bool) -> Bool {
        self.mode == mode && Float.valuesEqual(self.preAmp, preAmp, tolerance: 0.001) && self.preventClipping == preventClipping
    }
}
