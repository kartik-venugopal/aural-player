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

///
/// Persistent state for the Pitch Shift effects unit.
///
/// - SeeAlso:  `PitchShiftUnit`
///
struct PitchShiftUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [PitchShiftPresetPersistentState]?
    let renderQuality: Int?
    
    let pitch: Float?
}

///
/// Persistent state for a single Pitch Shift effects unit preset.
///
/// - SeeAlso:  `PitchShiftPreset`
///
struct PitchShiftPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let pitch: Float?
    
    init(preset: PitchShiftPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.pitch = preset.pitch
    }
}
