//
//  MasterUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

protocol MasterUnitProtocol: EffectsUnitProtocol {}

///
/// A "master" effects unit that does not directly manipulate audio, but
/// controls all other ("slave") effects units that do manipulate audio.
///
/// This unit provides 2 main functions:
/// 1. Acts as a "master on/off switch" to enable / disable all effects at once.
/// 2. Provides a way to capture all audio effects in a single preset object that can be saved and reused.
///
class MasterUnit: EffectsUnit, MasterUnitProtocol {
    
    let presets: MasterPresets
    
    var eqUnit: EQUnit
    var pitchShiftUnit: PitchShiftUnit
    var timeStretchUnit: TimeStretchUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit
    
    var nativeSlaveUnits: [EffectsUnit]
    var audioUnits: [HostedAudioUnit]

    init(persistentState: MasterUnitPersistentState?, nativeSlaveUnits: [EffectsUnit], audioUnits: [HostedAudioUnit]) {
        
        self.nativeSlaveUnits = nativeSlaveUnits
        
        eqUnit = nativeSlaveUnits.first(where: {$0 is EQUnit}) as! EQUnit
        pitchShiftUnit = nativeSlaveUnits.first(where: {$0 is PitchShiftUnit}) as! PitchShiftUnit
        timeStretchUnit = nativeSlaveUnits.first(where: {$0 is TimeStretchUnit}) as! TimeStretchUnit
        reverbUnit = nativeSlaveUnits.first(where: {$0 is ReverbUnit}) as! ReverbUnit
        delayUnit = nativeSlaveUnits.first(where: {$0 is DelayUnit}) as! DelayUnit
        filterUnit = nativeSlaveUnits.first(where: {$0 is FilterUnit}) as! FilterUnit
        
        self.audioUnits = audioUnits
        presets = MasterPresets(persistentState: persistentState)
        
        super.init(unitType: .master, unitState: persistentState?.state ?? AudioGraphDefaults.masterState)
        
        messenger.subscribe(to: .effects_unitActivated, handler: ensureActive)
    }
    
    override func toggleState() -> EffectsUnitState {
        
        if super.toggleState() == .bypassed {

            // Active -> Inactive
            // If a unit was active (i.e. not bypassed), deactivate it (mark it as
            // now being suppressed by the master bypass).
            
            nativeSlaveUnits.forEach {$0.suppress()}
            audioUnits.forEach {$0.suppress()}
            
        } else {
            
            // Inactive -> Active
            // If a unit was inactive (i.e. bypassed), activate it.
            
            nativeSlaveUnits.forEach {$0.unsuppress()}
            audioUnits.forEach {$0.unsuppress()}
        }
        
        return state
    }
    
    override func savePreset(named presetName: String) {
        
        let eqPreset = eqUnit.settingsAsPreset
        eqPreset.name = "EQ settings for Master preset: '\(presetName)'"
        
        let pitchPreset = pitchShiftUnit.settingsAsPreset
        pitchPreset.name = "Pitch settings for Master preset: '\(presetName)'"
        
        let timePreset = timeStretchUnit.settingsAsPreset
        timePreset.name = "Time settings for Master preset: '\(presetName)'"
        
        let reverbPreset = reverbUnit.settingsAsPreset
        reverbPreset.name = "Reverb settings for Master preset: '\(presetName)'"
        
        let delayPreset = delayUnit.settingsAsPreset
        delayPreset.name = "Delay settings for Master preset: '\(presetName)'"
        
        let filterPreset = filterUnit.settingsAsPreset
        filterPreset.name = "Filter settings for Master preset: '\(presetName)'"
        
        // Save the new preset
        let masterPreset = MasterPreset(name: presetName, eq: eqPreset, pitch: pitchPreset,
                                        time: timePreset, reverb: reverbPreset, delay: delayPreset,
                                        filter: filterPreset, systemDefined: false)
        
        presets.addPreset(masterPreset)
    }
    
    var settingsAsPreset: MasterPreset {
        
        let eqPreset = eqUnit.settingsAsPreset
        let pitchPreset = pitchShiftUnit.settingsAsPreset
        let timePreset = timeStretchUnit.settingsAsPreset
        let reverbPreset = reverbUnit.settingsAsPreset
        let delayPreset = delayUnit.settingsAsPreset
        let filterPreset = filterUnit.settingsAsPreset
        
        return MasterPreset(name: "masterSettings", eq: eqPreset, pitch: pitchPreset,
                            time: timePreset, reverb: reverbPreset, delay: delayPreset,
                            filter: filterPreset, systemDefined: false)
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
        eqUnit.applyPreset(preset.eq)
        eqUnit.state = preset.eq.state
        
        pitchShiftUnit.applyPreset(preset.pitch)
        pitchShiftUnit.state = preset.pitch.state
        
        timeStretchUnit.applyPreset(preset.time)
        timeStretchUnit.state = preset.time.state
        
        reverbUnit.applyPreset(preset.reverb)
        reverbUnit.state = preset.reverb.state
        
        delayUnit.applyPreset(preset.delay)
        delayUnit.state = preset.delay.state
        
        filterUnit.applyPreset(preset.filter)
        filterUnit.state = preset.filter.state
    }
    
    func addAudioUnit(_ unit: HostedAudioUnit) {
        audioUnits.append(unit)
    }
    
    func removeAudioUnits(at descendingIndices: [Int]) {
        descendingIndices.forEach {audioUnits.remove(at: $0)}
    }
    
    var persistentState: MasterUnitPersistentState {

        MasterUnitPersistentState(state: state,
                                  userPresets: presets.userDefinedPresets.map {MasterPresetPersistentState(preset: $0)})
    }
}
