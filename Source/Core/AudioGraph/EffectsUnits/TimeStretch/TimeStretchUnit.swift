//
//  TimeStretchUnit.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that applies a "time stretch" effect to an audio signal,
/// i.e. changes the playback rate of the signal. Optionally, the pitch of the input signal can also be
/// adjusted, thus syncing the pitch and playback rate.
///
/// - SeeAlso: `TimeUnitProtocol`
///
class TimeStretchUnit: EffectsUnit, TimeStretchUnitProtocol {
    
    let node: VariableRateNode = VariableRateNode()
    let presets: TimeStretchPresets
    
    init(persistentState: TimeStretchUnitPersistentState?) {
        
        presets = TimeStretchPresets(persistentState: persistentState)
        super.init(unitType: .time, unitState: persistentState?.state ?? AudioGraphDefaults.timeStretchState, renderQuality: persistentState?.renderQuality)
        
        rate = persistentState?.rate ?? AudioGraphDefaults.timeStretchRate
        shiftPitch = persistentState?.shiftPitch ?? AudioGraphDefaults.timeStretchShiftPitch
    }
    
    override var avNodes: [AVAudioNode] {node.avNodes}

    var rate: Float {
        
        get {node.rate}
        set {node.rate = newValue}
    }
    
    var shiftPitch: Bool {
        
        get {node.shiftPitch}
        set {node.shiftPitch = newValue}
    }
    
    var pitch: Float {
        node.pitch
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(named presetName: String) {
        
        let newPreset = TimeStretchPreset(name: presetName, state: .active, rate: node.rate,
                                          shiftPitch: node.shiftPitch, systemDefined: false)
        presets.addObject(newPreset)
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        rate = preset.rate
        shiftPitch = preset.shiftPitch
    }
    
    var settingsAsPreset: TimeStretchPreset {
        
        TimeStretchPreset(name: "timeSettings", state: state, rate: rate,
                          shiftPitch: shiftPitch, systemDefined: false)
    }
    
    var persistentState: TimeStretchUnitPersistentState {

        TimeStretchUnitPersistentState(state: state,
                                       userPresets: presets.userDefinedObjects.map {TimeStretchPresetPersistentState(preset: $0)},
                                       renderQuality: renderQualityPersistentState,
                                       rate: rate,
                                       shiftPitch: shiftPitch)
    }
}
