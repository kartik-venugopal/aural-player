//
//  DelayUnit.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that produces an echo effect by repeatedly
/// replaying the original input signal after a configurable delay. Each replayed
/// signal decays over time, creating a repeating and decaying echo.
///
/// - SeeAlso: `DelayUnitProtocol`
///
class DelayUnit: EffectsUnit, DelayUnitProtocol {
    
    let node: AVAudioUnitDelay = AVAudioUnitDelay()
    let presets: DelayPresets
    var currentPreset: DelayPreset? = nil
    
    init(persistentState: DelayUnitPersistentState?) {
        
        presets = DelayPresets(persistentState: persistentState)
        super.init(unitType: .delay, unitState: persistentState?.state ?? AudioGraphDefaults.delayState, renderQuality: persistentState?.renderQuality)
        
        time = persistentState?.time ?? AudioGraphDefaults.delayTime
        amount = persistentState?.amount ?? AudioGraphDefaults.delayAmount
        feedback = persistentState?.feedback ?? AudioGraphDefaults.delayFeedback
        lowPassCutoff = persistentState?.lowPassCutoff ?? AudioGraphDefaults.delayLowPassCutoff
        
        if let currentPresetName = persistentState?.currentPresetName,
            let matchingPreset = presets.object(named: currentPresetName) {
            
            currentPreset = matchingPreset
        }
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    override func reset() {
        node.reset()
    }
    
    var amount: Float {
        
        get {node.wetDryMix}
        set {node.wetDryMix = newValue}
    }
    
    var time: Double {
        
        get {node.delayTime}
        set {node.delayTime = newValue}
    }
    
    var feedback: Float {
        
        get {node.feedback}
        set {node.feedback = newValue}
    }
    
    var lowPassCutoff: Float {
        
        get {node.lowPassCutoff}
        set {node.lowPassCutoff = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(named presetName: String) {
        
        let newPreset = DelayPreset(name: presetName, state: .active, amount: amount,
                                    time: time, feedback: feedback, cutoff: lowPassCutoff, systemDefined: false)
        presets.addObject(newPreset)
        currentPreset = newPreset
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        time = preset.time
        amount = preset.amount
        feedback = preset.feedback
        lowPassCutoff = preset.lowPassCutoff
    }
    
    var settingsAsPreset: DelayPreset {
        
        DelayPreset(name: "delaySettings", state: state, amount: amount, time: time,
                    feedback: feedback, cutoff: lowPassCutoff, systemDefined: false)
    }
    
    private func presetsDeleted(_ presetNames: [String]) {
        
        if let theCurrentPreset = currentPreset, theCurrentPreset.userDefined, presetNames.contains(theCurrentPreset.name) {
            currentPreset = nil
        }
    }
    
    var persistentState: DelayUnitPersistentState {

        DelayUnitPersistentState(state: state,
                                 userPresets: presets.userDefinedObjects.map {DelayPresetPersistentState(preset: $0)},
                                 currentPresetName: currentPreset?.name,
                                 renderQuality: renderQualityPersistentState,
                                 amount: amount,
                                 time: time,
                                 feedback: feedback,
                                 lowPassCutoff: lowPassCutoff)
    }
}
