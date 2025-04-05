//
//  TimeStretchUnitPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Time Stretch effects unit.
///
/// - SeeAlso:  `TimeStretchUnit`
///
struct TimeStretchUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [TimeStretchPresetPersistentState]?
    let renderQuality: Int?
    
    let rate: Float?
    let shiftPitch: Bool?
    
    init(state: EffectsUnitState?, userPresets: [TimeStretchPresetPersistentState]?, renderQuality: Int?, rate: Float?, shiftPitch: Bool?) {
        
        self.state = state
        self.userPresets = userPresets
        self.renderQuality = renderQuality
        self.rate = rate
        self.shiftPitch = shiftPitch
    }
    
    init(legacyPersistentState: LegacyTimeStretchUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {TimeStretchPresetPersistentState(legacyPersistentState: $0)}
        self.renderQuality = legacyPersistentState?.renderQuality
        
        self.rate = legacyPersistentState?.rate
        self.shiftPitch = legacyPersistentState?.shiftPitch
    }
}

///
/// Persistent state for a single Time Stretch effects unit preset.
///
/// - SeeAlso:  `TimeStretchPreset`
///
struct TimeStretchPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let rate: Float?
    let shiftPitch: Bool?
    
    init(preset: TimeStretchPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.rate = preset.rate
        self.shiftPitch = preset.shiftPitch
    }
    
    init(legacyPersistentState: LegacyTimeStretchPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        
        self.rate = legacyPersistentState?.rate
        self.shiftPitch = legacyPersistentState?.shiftPitch
    }
}
