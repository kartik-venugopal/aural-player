//
//  PitchShiftUnitPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    let currentPresetName: String?
    let renderQuality: Int?
    
    let pitch: Float?
    
    init(state: EffectsUnitState?, userPresets: [PitchShiftPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, pitch: Float?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        self.pitch = pitch
    }
    
    init(legacyPersistentState: LegacyPitchShiftUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {PitchShiftPresetPersistentState(legacyPersistentState: $0)}
        self.currentPresetName = legacyPersistentState?.currentPresetName
        self.renderQuality = legacyPersistentState?.renderQuality
        
        self.pitch = legacyPersistentState?.pitch
    }
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
    
    init(legacyPersistentState: LegacyPitchShiftPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.pitch = legacyPersistentState?.pitch
    }
}
