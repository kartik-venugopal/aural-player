//
//  MasterUnitPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    init(state: EffectsUnitState?, userPresets: [MasterPresetPersistentState]?, currentPresetName: String?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
    }
    
    init(legacyPersistentState: LegacyMasterUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {MasterPresetPersistentState(legacyPersistentState: $0)}
        self.currentPresetName = legacyPersistentState?.currentPresetName
    }
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
    let pitchShift: PitchShiftPresetPersistentState?
    let timeStretch: TimeStretchPresetPersistentState?
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
        self.pitchShift = PitchShiftPresetPersistentState(preset: preset.pitch)
        self.timeStretch = TimeStretchPresetPersistentState(preset: preset.time)
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
    
    init(legacyPersistentState: LegacyMasterPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        
        self.eq = EQPresetPersistentState(legacyPersistentState: legacyPersistentState?.eq)
        self.pitchShift = PitchShiftPresetPersistentState(legacyPersistentState: legacyPersistentState?.pitch)
        self.timeStretch = TimeStretchPresetPersistentState(legacyPersistentState: legacyPersistentState?.time)
        self.reverb = ReverbPresetPersistentState(legacyPersistentState: legacyPersistentState?.reverb)
        self.delay = DelayPresetPersistentState(legacyPersistentState: legacyPersistentState?.delay)
        self.filter = FilterPresetPersistentState(legacyPersistentState: legacyPersistentState?.filter)
        
        self.nameOfCurrentMasterPreset = legacyPersistentState?.nameOfCurrentMasterPreset
        self.nameOfCurrentEQPreset = legacyPersistentState?.nameOfCurrentEQPreset
        self.nameOfCurrentPitchShiftPreset = legacyPersistentState?.nameOfCurrentPitchShiftPreset
        self.nameOfCurrentTimeStretchPreset = legacyPersistentState?.nameOfCurrentTimeStretchPreset
        self.nameOfCurrentReverbPreset = legacyPersistentState?.nameOfCurrentReverbPreset
        self.nameOfCurrentDelayPreset = legacyPersistentState?.nameOfCurrentDelayPreset
        self.nameOfCurrentFilterPreset = legacyPersistentState?.nameOfCurrentFilterPreset
    }
}
