import AVFoundation

class DelayUnit: FXUnit, DelayUnitProtocol {
    
    override var state: EffectsUnitState {
        didSet {node.bypass = state != .active}
    }
    
    private let node: AVAudioUnitDelay = AVAudioUnitDelay()
    let presets: DelayPresets = DelayPresets()
    
    init(_ appState: AudioGraphState) {
        
        let delayState = appState.delayUnitState
        
        super.init(.delay, delayState.unitState)
        node.bypass = state != .active
        
        time = delayState.time
        amount = delayState.amount
        feedback = delayState.feedback
        lowPassCutoff = delayState.lowPassCutoff
        
        presets.addPresets(delayState.userPresets)
    }
    
    var avNodes: [AVAudioNode] {return [node]}
    
    override func reset() {
        node.reset()
    }
    
    var amount: Float {
        
        get {return node.wetDryMix}
        set(newValue) {node.wetDryMix = newValue}
    }
    
    var time: Double {
        
        get {return node.delayTime}
        set(newValue) {node.delayTime = newValue}
    }
    
    var feedback: Float {
        
        get {return node.feedback}
        set(newValue) {node.feedback = newValue}
    }
    
    var lowPassCutoff: Float {
        
        get {return node.lowPassCutoff}
        set(newValue) {node.lowPassCutoff = newValue}
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(DelayPreset(presetName, state, amount, time, feedback, lowPassCutoff, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            
            time = preset.time
            amount = preset.amount
            feedback = preset.feedback
            lowPassCutoff = preset.cutoff
        }
    }
    
    func getSettingsAsPreset() -> DelayPreset {
        return DelayPreset("delaySettings", state, amount, time, feedback, lowPassCutoff, false)
    }
    
    func persistentState() -> DelayUnitState {

        let unitState = DelayUnitState()

        unitState.unitState = state
        unitState.time = time
        unitState.amount = amount
        unitState.feedback = feedback
        unitState.lowPassCutoff = lowPassCutoff
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
