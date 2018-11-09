import Foundation
import AVFoundation

class ReverbUnit: FXUnit, ReverbUnitProtocol {
    
    override var state: EffectsUnitState {
        didSet {node.bypass = state != .active}
    }
    
    private let node: AVAudioUnitReverb = AVAudioUnitReverb()
    let presets: ReverbPresets = ReverbPresets()
    
    var avSpace: AVAudioUnitReverbPreset {
        didSet {node.loadFactoryPreset(avSpace)}
    }
    
    init(_ appState: AudioGraphState) {
        
        let reverbState = appState.reverbUnitState
        
        avSpace = reverbState.space.avPreset
        super.init(.reverb, reverbState.unitState)
        node.bypass = state != .active
        
        amount = reverbState.amount
        presets.addPresets(reverbState.userPresets)
    }
    
    var avNodes: [AVAudioNode] {return [node]}
    
    func reset() {
        node.reset()
    }
    
    var space: ReverbSpaces {
        
        get {return ReverbSpaces.mapFromAVPreset(avSpace)}
        set(newValue) {avSpace = newValue.avPreset}
    }
    
    var amount: Float {
        
        get {return node.wetDryMix}
        set(newValue) {node.wetDryMix = newValue}
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(ReverbPreset(presetName, state, space, amount, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            space = preset.space
            amount = preset.amount
        }
    }
    
    func getSettingsAsPreset() -> ReverbPreset {
        return ReverbPreset("", state, space, amount, false)
    }
    
    func persistentState() -> ReverbUnitState {

        let unitState = ReverbUnitState()

        unitState.unitState = state
        unitState.space = space
        unitState.amount = amount
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
