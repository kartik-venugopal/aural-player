//
//  PitchShiftUnit.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    private let node: AVAudioUnitTimePitch = .init()
    let presets: PitchShiftPresets = .init()
    
    let minPitch: Float = -2400
    let maxPitch: Float = 2400
    private lazy var pitchRange: ClosedRange<Float> = minPitch...maxPitch
    
    init() {
        super.init(unitType: .pitch)
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    var pitch: PitchShift {
        
        get {PitchShift(fromCents: node.pitch)}
        set {node.pitch = newValue.asCentsFloat.clamped(to: pitchRange)}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    func increasePitch(by pitchShift: PitchShift, ensureActive: Bool) -> PitchShift {
        
        if ensureActive {
            ensureActiveAndReset()
        }
        
        node.pitch = (node.pitch + pitchShift.asCentsFloat).clamped(to: pitchRange)
        return pitch
    }
    
    func increasePitch(by cents: Float, ensureActive: Bool) -> PitchShift {
        
        if ensureActive {
            ensureActiveAndReset()
        }
        
        node.pitch = (node.pitch + cents).clamped(to: pitchRange)
        return pitch
    }
    
    func decreasePitch(by pitchShift: PitchShift, ensureActive: Bool) -> PitchShift {
        
        if ensureActive {
            ensureActiveAndReset()
        }
        
        node.pitch = (node.pitch - pitchShift.asCentsFloat).clamped(to: pitchRange)
        return pitch
    }
    
    func decreasePitch(by cents: Float, ensureActive: Bool) -> PitchShift {
        
        if ensureActive {
            ensureActiveAndReset()
        }
        
        node.pitch = (node.pitch - cents).clamped(to: pitchRange)
        return pitch
    }
    
    override func savePreset(named presetName: String) {
        
        let newPreset = PitchShiftPreset(name: presetName, state: .active, pitch: node.pitch, systemDefined: false)
        presets.addObject(newPreset)
    }

    override func applyPreset(named presetName: String) {

        if let preset = presets.object(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        node.pitch = preset.pitch
    }
    
    var settingsAsPreset: PitchShiftPreset {
        PitchShiftPreset(name: "pitchSettings", state: state, pitch: node.pitch, systemDefined: false)
    }
    
    override func reset() {
        node.pitch = 0
    }
    
    var persistentState: PitchShiftUnitPersistentState {
        
        PitchShiftUnitPersistentState(state: state,
                                      userPresets: presets.userDefinedObjects.map {PitchShiftPresetPersistentState(preset: $0)},
                                      renderQuality: renderQualityPersistentState,
                                      pitch: node.pitch)
    }
}
