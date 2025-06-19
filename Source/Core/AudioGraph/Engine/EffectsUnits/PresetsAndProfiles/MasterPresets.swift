//
//  MasterPresets.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Master effects unit.
///
class MasterPresets: EffectsUnitPresets<MasterPreset> {
    
    func initialize(persistentState: MasterUnitPersistentState?) {
        
        super.initialize(systemDefinedObjects: [],
                   userDefinedObjects: (persistentState?.userPresets ?? []).compactMap {MasterPreset(persistentState: $0)})
    }
}

///
/// Represents a single Master effects unit preset, i.e. encapsulates
/// all effects settings in a single preset.
///
class MasterPreset: EffectsUnitPreset {
    
    let eq: EQPreset
    let pitch: PitchShiftPreset
    let time: TimeStretchPreset
    let reverb: ReverbPreset
    let delay: DelayPreset
    let filter: FilterPreset
    
    init(name: String, eq: EQPreset, pitch: PitchShiftPreset, time: TimeStretchPreset,
         reverb: ReverbPreset, delay: DelayPreset, filter: FilterPreset, systemDefined: Bool) {
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        
        super.init(name: name, state: .active, systemDefined: systemDefined)
    }
    
    init?(persistentState: MasterPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let eq = persistentState.eq, let eqPreset = EQPreset(persistentState: eq),
              let pitch = persistentState.pitchShift, let pitchPreset = PitchShiftPreset(persistentState: pitch),
              let time = persistentState.timeStretch, let timePreset = TimeStretchPreset(persistentState: time),
              let reverb = persistentState.reverb, let reverbPreset = ReverbPreset(persistentState: reverb),
              let delay = persistentState.delay, let delayPreset = DelayPreset(persistentState: delay),
              let filter = persistentState.filter, let filterPreset = FilterPreset(persistentState: filter)
        else {return nil}
        
        self.eq = eqPreset
        self.pitch = pitchPreset
        self.time = timePreset
        self.reverb = reverbPreset
        self.delay = delayPreset
        self.filter = filterPreset
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
}
