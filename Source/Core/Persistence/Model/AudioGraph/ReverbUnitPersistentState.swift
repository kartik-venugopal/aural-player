//
//  ReverbUnitPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Reverb effects unit.
///
/// - SeeAlso:  `ReverbUnit`
///
struct ReverbUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [ReverbPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let space: ReverbSpace?
    let amount: Float?
    
    init(state: EffectsUnitState?, userPresets: [ReverbPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, space: ReverbSpace?, amount: Float?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        self.space = space
        self.amount = amount
    }
    
    init(legacyPersistentState: LegacyReverbUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {ReverbPresetPersistentState(legacyPersistentState: $0)}
        self.currentPresetName = legacyPersistentState?.currentPresetName
        self.renderQuality = legacyPersistentState?.renderQuality
        
        self.space = legacyPersistentState?.space
        self.amount = legacyPersistentState?.amount
    }
}

///
/// Persistent state for a single Reverb effects unit preset.
///
/// - SeeAlso:  `ReverbPreset`
///
struct ReverbPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let space: ReverbSpace?
    let amount: Float?
    
    init(preset: ReverbPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.space = preset.space
        self.amount = preset.amount
    }
    
    init(legacyPersistentState: LegacyReverbPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        
        self.space = legacyPersistentState?.space
        self.amount = legacyPersistentState?.amount
    }
}
