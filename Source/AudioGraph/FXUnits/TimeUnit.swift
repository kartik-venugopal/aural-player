//
//  TimeUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A functional contract for an effects unit that applies a "time stretch" effect to an audio signal,
/// i.e. changes the playback rate of the signal. Optionally, the pitch of the input signal can also be
/// adjusted, thus syncing the pitch and playback rate.
///
protocol TimeUnitProtocol: EffectsUnitProtocol {
    
    // The playback rate, specified as a value between 1/32 and 32
    var rate: Float {get set}
    
    // The amount of overlap between segments of the input audio signal into the time effects unit, specified as a value between 3 and 32
    var overlap: Float {get set}
    
    // An option to alter the pitch of the sound, along with the rate
    var shiftPitch: Bool {get set}
    
    // Returns the pitch offset of the time audio effects unit. If the pitch shift option of the unit is enabled, this value will range between -2400 and +2400 cents. It will be 0 otherwise (i.e. pitch unaltered).
    var pitch: Float {get}
}

///
/// An effects unit that applies a "time stretch" effect to an audio signal,
/// i.e. changes the playback rate of the signal. Optionally, the pitch of the input signal can also be
/// adjusted, thus syncing the pitch and playback rate.
///
class TimeUnit: EffectsUnit, TimeUnitProtocol {
    
    private let node: VariableRateNode = VariableRateNode()
    let presets: TimePresets
    
    init(persistentState: TimeUnitPersistentState?) {
        
        presets = TimePresets(persistentState: persistentState)
        super.init(.time, persistentState?.state ?? AudioGraphDefaults.timeState)
        
        rate = persistentState?.rate ?? AudioGraphDefaults.timeStretchRate
        overlap = persistentState?.overlap ?? AudioGraphDefaults.timeOverlap
        shiftPitch = persistentState?.shiftPitch ?? AudioGraphDefaults.timeShiftPitch
    }
    
    override var avNodes: [AVAudioNode] {return [node.timePitchNode, node.variNode]}

    var rate: Float {
        
        get {return node.rate}
        set {node.rate = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        set {node.overlap = newValue}
    }
    
    var shiftPitch: Bool {
        
        get {return node.shiftPitch}
        set {node.shiftPitch = newValue}
    }
    
    var pitch: Float {
        return node.pitch
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(TimePreset(presetName, .active, node.rate, node.overlap, node.shiftPitch, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: TimePreset) {
        
        rate = preset.rate
        overlap = preset.overlap
        shiftPitch = preset.shiftPitch
    }
    
    var settingsAsPreset: TimePreset {
        return TimePreset("timeSettings", state, rate, overlap, shiftPitch, false)
    }
    
    var persistentState: TimeUnitPersistentState {

        let unitState = TimeUnitPersistentState()

        unitState.state = state
        unitState.rate = rate
        unitState.overlap = overlap
        unitState.shiftPitch = shiftPitch
        unitState.userPresets = presets.userDefinedPresets.map {TimePresetPersistentState(preset: $0)}

        return unitState
    }
}
