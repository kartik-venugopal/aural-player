//
//  MasterPresets.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Master effects unit.
///
class MasterPresets: EffectsUnitPresets<MasterPreset> {
    
    init(persistentState: MasterUnitPersistentState?) {
        
        super.init(systemDefinedObjects: [],
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

    var nameOfCurrentMasterPreset: String?  // Used only within SoundProfile
    let nameOfCurrentEQPreset: String?
    let nameOfCurrentPitchShiftPreset: String?
    let nameOfCurrentTimeStretchPreset: String?
    let nameOfCurrentReverbPreset: String?
    let nameOfCurrentDelayPreset: String?
    let nameOfCurrentFilterPreset: String?
    
    init(name: String, eq: EQPreset, pitch: PitchShiftPreset, time: TimeStretchPreset,
         reverb: ReverbPreset, delay: DelayPreset, filter: FilterPreset, nameOfCurrentMasterPreset: String?, nameOfCurrentEQPreset: String?, nameOfCurrentPitchShiftPreset: String?, nameOfCurrentTimeStretchPreset: String?, nameOfCurrentReverbPreset: String?, nameOfCurrentDelayPreset: String?, nameOfCurrentFilterPreset: String?, systemDefined: Bool) {
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        
        self.nameOfCurrentMasterPreset = nameOfCurrentMasterPreset
        self.nameOfCurrentEQPreset = nameOfCurrentEQPreset
        self.nameOfCurrentPitchShiftPreset = nameOfCurrentPitchShiftPreset
        self.nameOfCurrentTimeStretchPreset = nameOfCurrentTimeStretchPreset
        self.nameOfCurrentReverbPreset = nameOfCurrentReverbPreset
        self.nameOfCurrentDelayPreset = nameOfCurrentDelayPreset
        self.nameOfCurrentFilterPreset = nameOfCurrentFilterPreset
        
        super.init(name: name, state: .active, systemDefined: systemDefined)
    }
    
    init?(persistentState: MasterPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let eq = persistentState.eq, let eqPreset = EQPreset(persistentState: eq),
              let pitch = persistentState.pitch, let pitchPreset = PitchShiftPreset(persistentState: pitch),
              let time = persistentState.time, let timePreset = TimeStretchPreset(persistentState: time),
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
        
        self.nameOfCurrentMasterPreset = persistentState.nameOfCurrentMasterPreset
        self.nameOfCurrentEQPreset = persistentState.nameOfCurrentEQPreset
        self.nameOfCurrentPitchShiftPreset = persistentState.nameOfCurrentPitchShiftPreset
        self.nameOfCurrentTimeStretchPreset = persistentState.nameOfCurrentTimeStretchPreset
        self.nameOfCurrentReverbPreset = persistentState.nameOfCurrentReverbPreset
        self.nameOfCurrentDelayPreset = persistentState.nameOfCurrentDelayPreset
        self.nameOfCurrentFilterPreset = persistentState.nameOfCurrentFilterPreset
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
}
