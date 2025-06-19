//
//  ReverbUnit.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that applies a "reverb" effect, i.e. reverberation. The result
/// is that the output audio is perceived as being more roomy, as if it has traveled a distance,
/// bounced off walls and other barriers, i.e. that the sound has "reverberated".
///
/// - SeeAlso: `ReverbUnitProtocol`
///
class ReverbUnit: EffectsUnit, ReverbUnitProtocol {
    
    private let node: AVAudioUnitReverb = .init()
    let presets: ReverbPresets = .init()
    
    var avSpace: AVAudioUnitReverbPreset = AudioGraphDefaults.reverbSpace.avPreset {
        
        didSet {
            node.loadFactoryPreset(avSpace)
        }
    }
    
    init() {
        super.init(unitType: .reverb)
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    override func reset() {
        node.reset()
    }
    
    var space: ReverbSpace {
        
        get {.mapFromAVPreset(avSpace)}
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
    
    override func savePreset(named presetName: String) {
        
        let newPreset = ReverbPreset(name: presetName, state: .active,
                                     space: space, amount: amount, systemDefined: false)
        presets.addObject(newPreset)
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        space = preset.space
        amount = preset.amount
    }
    
    var settingsAsPreset: ReverbPreset {
        ReverbPreset(name: "reverbSettings", state: state, space: space, amount: amount, systemDefined: false)
    }
    
    var persistentState: ReverbUnitPersistentState {
        
        ReverbUnitPersistentState(state: state,
                                  userPresets: presets.userDefinedObjects.map {ReverbPresetPersistentState(preset: $0)},
                                  renderQuality: renderQualityPersistentState,
                                  space: space,
                                  amount: amount)
    }
}
