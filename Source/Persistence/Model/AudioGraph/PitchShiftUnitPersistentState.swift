//
//  PitchShiftUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct PitchShiftUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [PitchShiftPresetPersistentState]?
    
    let pitch: Float?
    let overlap: Float?
}

struct PitchShiftPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let pitch: Float?
    let overlap: Float?
    
    init(preset: PitchShiftPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.pitch = preset.pitch
        self.overlap = preset.overlap
    }
}
