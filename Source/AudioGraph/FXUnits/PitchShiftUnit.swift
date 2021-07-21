//
//  PitchShiftUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that applies a "pitch shift" effect to an audio signal, i.e. changes the pitch of the signal.
///
/// - SeeAlso: `PitchShiftUnitProtocol`
///
class PitchShiftUnit: EffectsUnit, PitchShiftUnitProtocol {
    
    let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchShiftPresets
    
    init(persistentState: PitchShiftUnitPersistentState?) {
        
        presets = PitchShiftPresets(persistentState: persistentState)
        super.init(unitType: .pitch, unitState: persistentState?.state ?? AudioGraphDefaults.pitchShiftState)
        
        node.pitch = persistentState?.pitch ?? AudioGraphDefaults.pitchShift
        node.overlap = persistentState?.overlap ?? AudioGraphDefaults.pitchShiftOverlap
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    var pitch: Float {
        
        get {node.pitch}
        set {node.pitch = newValue}
    }
    
    var overlap: Float {
        
        get {node.overlap}
        set {node.overlap = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(named presetName: String) {
        presets.addPreset(PitchShiftPreset(name: presetName, state: .active, pitch: pitch, overlap: overlap, systemDefined: false))
    }

    override func applyPreset(named presetName: String) {

        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        
        pitch = preset.pitch
        overlap = preset.overlap
    }
    
    var settingsAsPreset: PitchShiftPreset {
        PitchShiftPreset(name: "pitchSettings", state: state, pitch: pitch, overlap: overlap, systemDefined: false)
    }
    
    var persistentState: PitchShiftUnitPersistentState {
        
        PitchShiftUnitPersistentState(state: state,
                                      userPresets: presets.userDefinedPresets.map {PitchShiftPresetPersistentState(preset: $0)},
                                      pitch: pitch,
                                      overlap: overlap)
    }
}
