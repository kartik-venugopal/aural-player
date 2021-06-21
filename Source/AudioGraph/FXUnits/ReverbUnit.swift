import AVFoundation

class ReverbUnit: FXUnit, ReverbUnitProtocol {
    
    private let node: AVAudioUnitReverb = AVAudioUnitReverb()
    let presets: ReverbPresets = ReverbPresets()
    
    init(persistentState: ReverbUnitPersistentState?) {
        
        avSpace = (persistentState?.space ?? AudioGraphDefaults.reverbSpace).avPreset
        super.init(.reverb, persistentState?.state ?? AudioGraphDefaults.reverbState)
        
        amount = persistentState?.amount ?? AudioGraphDefaults.delayAmount
        presets.addPresets((persistentState?.userPresets ?? []).map {ReverbPreset(persistentState: $0)})
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    override func reset() {
        node.reset()
    }
    
    var avSpace: AVAudioUnitReverbPreset {
        didSet {node.loadFactoryPreset(avSpace)}
    }
    
    var space: ReverbSpaces {
        
        get {return ReverbSpaces.mapFromAVPreset(avSpace)}
        set(newValue) {avSpace = newValue.avPreset}
    }
    
    var amount: Float {
        
        get {return node.wetDryMix}
        set(newValue) {node.wetDryMix = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(ReverbPreset(presetName, .active, space, amount, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        space = preset.space
        amount = preset.amount
    }
    
    var settingsAsPreset: ReverbPreset {
        return ReverbPreset("reverbSettings", state, space, amount, false)
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
