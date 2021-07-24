//
//  TimeStretchUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        super.init(unitType: .time, unitState: persistentState?.state ?? AudioGraphDefaults.timeStretchState)
        
        rate = persistentState?.rate ?? AudioGraphDefaults.timeStretchRate
        overlap = persistentState?.overlap ?? AudioGraphDefaults.timeStretchOverlap
        shiftPitch = persistentState?.shiftPitch ?? AudioGraphDefaults.timeStretchShiftPitch
    }
    
    override var avNodes: [AVAudioNode] {node.avNodes}

    var rate: Float {
        
        get {node.rate}
        set {node.rate = newValue}
    }
    
    var overlap: Float {
        
        get {node.overlap}
        set {node.overlap = newValue}
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
        
        presets.addPreset(TimeStretchPreset(name: presetName, state: .active, rate: node.rate,
                                            overlap: node.overlap, shiftPitch: node.shiftPitch, systemDefined: false))
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        rate = preset.rate
        overlap = preset.overlap
        shiftPitch = preset.shiftPitch
    }
    
    var settingsAsPreset: TimeStretchPreset {
        
        TimeStretchPreset(name: "timeSettings", state: state, rate: rate, overlap: overlap,
                          shiftPitch: shiftPitch, systemDefined: false)
    }
    
    var persistentState: TimeStretchUnitPersistentState {

        TimeStretchUnitPersistentState(state: state,
                                       userPresets: presets.userDefinedPresets.map {TimeStretchPresetPersistentState(preset: $0)},
                                       rate: rate,
                                       shiftPitch: shiftPitch,
                                       overlap: overlap)
    }
}
