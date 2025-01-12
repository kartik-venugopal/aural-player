//
//  DelayUnitPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Delay effects unit.
///
/// - SeeAlso:  `DelayUnit`
///
struct DelayUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [DelayPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let amount: Float?
    let time: Double?
    let feedback: Float?
    let lowPassCutoff: Float?
    
    init(state: EffectsUnitState?, userPresets: [DelayPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, amount: Float?, time: Double?, feedback: Float?, lowPassCutoff: Float?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
    }
    
    init(legacyPersistentState: LegacyDelayUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {DelayPresetPersistentState(legacyPersistentState: $0)}
        self.currentPresetName = legacyPersistentState?.currentPresetName
        self.renderQuality = legacyPersistentState?.renderQuality
        
        self.amount = legacyPersistentState?.amount
        self.time = legacyPersistentState?.time
        self.feedback = legacyPersistentState?.feedback
        self.lowPassCutoff = legacyPersistentState?.lowPassCutoff
    }
}

///
/// Persistent state for a single Delay effects unit preset.
///
/// - SeeAlso:  `DelayPreset`
///
struct DelayPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let amount: Float?
    let time: Double?
    let feedback: Float?
    let lowPassCutoff: Float?
    
    init(preset: DelayPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.amount = preset.amount
        self.time = preset.time
        self.feedback = preset.feedback
        self.lowPassCutoff = preset.lowPassCutoff
    }
    
    init(legacyPersistentState: LegacyDelayPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        
        self.amount = legacyPersistentState?.amount
        self.time = legacyPersistentState?.time
        self.feedback = legacyPersistentState?.feedback
        self.lowPassCutoff = legacyPersistentState?.lowPassCutoff
    }
}
