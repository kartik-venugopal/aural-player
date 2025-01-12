//
//  EQUnitPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Equalizer effects unit.
///
/// - SeeAlso:  `EQUnit`
///
struct EQUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [EQPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let globalGain: Float?
    let bands: [Float]?
    
    init(state: EffectsUnitState?, userPresets: [EQPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, globalGain: Float?, bands: [Float]?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        self.globalGain = globalGain
        self.bands = bands
    }
    
    init(legacyPersistentState: LegacyEQUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {EQPresetPersistentState(legacyPersistentState: $0)}
        self.currentPresetName = legacyPersistentState?.currentPresetName
        self.renderQuality = legacyPersistentState?.renderQuality
        
        self.globalGain = legacyPersistentState?.globalGain
        self.bands = legacyPersistentState?.bands
    }
}

///
/// Persistent state for a single Equalizer effects unit preset.
///
/// - SeeAlso:  `EQPreset`
///
struct EQPresetPersistentState: Codable {

    let name: String?
    let state: EffectsUnitState?
    
    let bands: [Float]?
    let globalGain: Float?
    
    init(preset: EQPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.bands = preset.bands
        self.globalGain = preset.globalGain
    }
    
    init(legacyPersistentState: LegacyEQPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        
        self.bands = legacyPersistentState?.bands
        self.globalGain = legacyPersistentState?.globalGain
    }
}
