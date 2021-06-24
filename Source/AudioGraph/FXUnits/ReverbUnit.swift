//
//  ReverbUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

protocol ReverbUnitProtocol: FXUnitProtocol {
    
    var space: ReverbSpaces {get set}
    
    var amount: Float {get set}
}

class ReverbUnit: FXUnit, ReverbUnitProtocol {
    
    private let node: AVAudioUnitReverb = AVAudioUnitReverb()
    let presets: ReverbPresets
    
    init(persistentState: ReverbUnitPersistentState?) {
        
        avSpace = (persistentState?.space ?? AudioGraphDefaults.reverbSpace).avPreset
        presets = ReverbPresets(persistentState: persistentState)
        super.init(.reverb, persistentState?.state ?? AudioGraphDefaults.reverbState)
        
        amount = persistentState?.amount ?? AudioGraphDefaults.delayAmount
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    override func reset() {
        node.reset()
    }
    
    var avSpace: AVAudioUnitReverbPreset {
        didSet {node.loadFactoryPreset(avSpace)}
    }
    
    var space: ReverbSpaces {
        
        get {ReverbSpaces.mapFromAVPreset(avSpace)}
        set {avSpace = newValue.avPreset}
    }
    
    var amount: Float {
        
        get {node.wetDryMix}
        set {node.wetDryMix = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(ReverbPreset(presetName, .active, space, amount, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        space = preset.space
        amount = preset.amount
    }
    
    var settingsAsPreset: ReverbPreset {
        ReverbPreset("reverbSettings", state, space, amount, false)
    }
    
    var persistentState: ReverbUnitPersistentState {

        let unitState = ReverbUnitPersistentState()

        unitState.state = state
        unitState.space = space
        unitState.amount = amount
        unitState.userPresets = presets.userDefinedPresets.map {ReverbPresetPersistentState(preset: $0)}

        return unitState
    }
}
