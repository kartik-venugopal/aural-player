//
//  ReplayGainUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct ReplayGainUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [ReplayGainPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let mode: ReplayGainMode?
    let preAmp: Float?
    
    init(state: EffectsUnitState?, userPresets: [ReplayGainPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, mode: ReplayGainMode?, preAmp: Float?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        
        self.mode = mode
        self.preAmp = preAmp
    }
}

struct ReplayGainPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let mode: ReplayGainMode?
    let preAmp: Float?
    
    init(preset: ReplayGainPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.mode = preset.mode
        self.preAmp = preset.preAmp
    }
}
