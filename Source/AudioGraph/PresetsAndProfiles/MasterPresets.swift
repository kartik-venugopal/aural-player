//
//  MasterPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Master effects unit.
///
class MasterPresets: EffectsPresets<MasterPreset> {
    
    init(persistentState: MasterUnitPersistentState?) {
        
        super.init(systemDefinedPresets: [],
                   userDefinedPresets: (persistentState?.userPresets ?? []).map {MasterPreset(persistentState: $0)})
    }
}

///
/// Represents a single Master effects unit preset, i.e. encapsulates
/// all effects settings in a single preset.
///
class MasterPreset: EffectsUnitPreset {
    
    let eq: EQPreset
    let pitch: PitchPreset
    let time: TimePreset
    let reverb: ReverbPreset
    let delay: DelayPreset
    let filter: FilterPreset
    
    init(_ name: String, _ eq: EQPreset, _ pitch: PitchPreset, _ time: TimePreset, _ reverb: ReverbPreset, _ delay: DelayPreset, _ filter: FilterPreset, _ systemDefined: Bool) {
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        
        super.init(name, .active, systemDefined)
    }
    
    init(persistentState: MasterPresetPersistentState) {
        
        self.eq = EQPreset(persistentState: persistentState.eq)
        self.pitch = PitchPreset(persistentState: persistentState.pitch)
        self.time = TimePreset(persistentState: persistentState.time)
        self.reverb = ReverbPreset(persistentState: persistentState.reverb)
        self.delay = DelayPreset(persistentState: persistentState.delay)
        self.filter = FilterPreset(persistentState: persistentState.filter)
        
        super.init(persistentState: persistentState)
    }
}
