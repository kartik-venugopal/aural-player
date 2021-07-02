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

class MasterUnitPersistentState: EffectsUnitPersistentState<MasterPresetPersistentState> {}

class MasterPresetPersistentState: EffectsUnitPresetPersistentState {
    
    let eq: EQPresetPersistentState
    let pitch: PitchShiftPresetPersistentState
    let time: TimeStretchPresetPersistentState
    let reverb: ReverbPresetPersistentState
    let delay: DelayPresetPersistentState
    let filter: FilterPresetState
    
    init(preset: MasterPreset) {
        
        self.eq = EQPresetPersistentState(preset: preset.eq)
        self.pitch = PitchShiftPresetPersistentState(preset: preset.pitch)
        self.time = TimeStretchPresetPersistentState(preset: preset.time)
        self.reverb = ReverbPresetPersistentState(preset: preset.reverb)
        self.delay = DelayPresetPersistentState(preset: preset.delay)
        self.filter = FilterPresetState(preset: preset.filter)
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {

        guard let eq = map.persistentObjectValue(forKey: "eq", ofType: EQPresetPersistentState.self),
              let pitch = map.persistentObjectValue(forKey: "pitch", ofType: PitchShiftPresetPersistentState.self),
              let time = map.persistentObjectValue(forKey: "time", ofType: TimeStretchPresetPersistentState.self),
              let reverb = map.persistentObjectValue(forKey: "reverb", ofType: ReverbPresetPersistentState.self),
              let delay = map.persistentObjectValue(forKey: "delay", ofType: DelayPresetPersistentState.self),
              let filter = map.persistentObjectValue(forKey: "filter", ofType: FilterPresetState.self) else {return nil}
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        
        super.init(map)
    }
}
