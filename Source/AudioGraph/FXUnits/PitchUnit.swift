//
//  PitchUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A functional contract for an effects unit that applies a "pitch shift" effect to an audio signal, i.e. changes the pitch of the signal.
///
protocol PitchShiftUnitProtocol: EffectsUnitProtocol {
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    var pitch: Float {get set}
    
    // the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    var overlap: Float {get set}
}

///
/// An effects unit that applies a "pitch shift" effect to an audio signal, i.e. changes the pitch of the signal.
///
/// - SeeAlso: `PitchShiftUnitProtocol`
///
class PitchUnit: EffectsUnit, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchPresets
    
    init(persistentState: PitchUnitPersistentState?) {
        
        presets = PitchPresets(persistentState: persistentState)
        super.init(.pitch, persistentState?.state ?? AudioGraphDefaults.pitchState)
        
        node.pitch = persistentState?.pitch ?? AudioGraphDefaults.pitch
        node.overlap = persistentState?.overlap ?? AudioGraphDefaults.pitchOverlap
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    var pitch: Float {
        
        get {return node.pitch}
        set {node.pitch = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        set {node.overlap = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(PitchPreset(presetName, .active, pitch, overlap, false))
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: PitchPreset) {
        
        pitch = preset.pitch
        overlap = preset.overlap
    }
    
    var settingsAsPreset: PitchPreset {
        return PitchPreset("pitchSettings", state, pitch, overlap, false)
    }
    
    var persistentState: PitchUnitPersistentState {
        
        let unitState = PitchUnitPersistentState()
        
        unitState.state = state
        unitState.pitch = pitch
        unitState.overlap = overlap
        unitState.userPresets = presets.userDefinedPresets.map {PitchPresetPersistentState(preset: $0)}
        
        return unitState
    }
}
