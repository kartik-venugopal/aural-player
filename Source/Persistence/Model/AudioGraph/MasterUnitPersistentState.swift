//
//  MasterUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Master effects unit.
///
/// - SeeAlso:  `MasterUnit`
///
struct MasterUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [MasterPresetPersistentState]?
    let currentPresetName: String?
}

///
/// Persistent state for a single Master effects unit preset.
///
/// - SeeAlso:  `MasterPreset`
///
struct MasterPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let eq: EQPresetPersistentState?
    let pitch: PitchShiftPresetPersistentState?
    let time: TimeStretchPresetPersistentState?
    let reverb: ReverbPresetPersistentState?
    let delay: DelayPresetPersistentState?
    let filter: FilterPresetPersistentState?
    
    let nameOfCurrentMasterPreset: String?
    let nameOfCurrentEQPreset: String?
    let nameOfCurrentPitchShiftPreset: String?
    let nameOfCurrentTimeStretchPreset: String?
    let nameOfCurrentReverbPreset: String?
    let nameOfCurrentDelayPreset: String?
    let nameOfCurrentFilterPreset: String?
    
    init(preset: MasterPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.eq = EQPresetPersistentState(preset: preset.eq)
        self.pitch = PitchShiftPresetPersistentState(preset: preset.pitch)
        self.time = TimeStretchPresetPersistentState(preset: preset.time)
        self.reverb = ReverbPresetPersistentState(preset: preset.reverb)
        self.delay = DelayPresetPersistentState(preset: preset.delay)
        self.filter = FilterPresetPersistentState(preset: preset.filter)
        
        self.nameOfCurrentMasterPreset = preset.nameOfCurrentMasterPreset
        self.nameOfCurrentEQPreset = preset.nameOfCurrentEQPreset
        self.nameOfCurrentPitchShiftPreset = preset.nameOfCurrentPitchShiftPreset
        self.nameOfCurrentTimeStretchPreset = preset.nameOfCurrentTimeStretchPreset
        self.nameOfCurrentReverbPreset = preset.nameOfCurrentReverbPreset
        self.nameOfCurrentDelayPreset = preset.nameOfCurrentDelayPreset
        self.nameOfCurrentFilterPreset = preset.nameOfCurrentFilterPreset
    }
}
