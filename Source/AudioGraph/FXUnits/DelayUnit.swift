import AVFoundation

class DelayUnit: FXUnit, DelayUnitProtocol {
    
    private let node: AVAudioUnitDelay = AVAudioUnitDelay()
    let presets: DelayPresets = DelayPresets()
    
    init(_ persistentState: AudioGraphState) {
        
        let delayState = persistentState.delayUnit
        
        super.init(.delay, delayState.state)
        
        time = delayState.time
        amount = delayState.amount
        feedback = delayState.feedback
        lowPassCutoff = delayState.lowPassCutoff
        
        presets.addPresets(delayState.userPresets)
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
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
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(DelayPreset(presetName, .active, amount, time, feedback, lowPassCutoff, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        time = preset.time
        amount = preset.amount
        feedback = preset.feedback
        lowPassCutoff = preset.lowPassCutoff
    }
    
    var settingsAsPreset: DelayPreset {
        return DelayPreset("delaySettings", state, amount, time, feedback, lowPassCutoff, false)
    }
    
    var persistentState: DelayUnitState {

        let unitState = DelayUnitState()

        unitState.state = state
        unitState.time = time
        unitState.amount = amount
        unitState.feedback = feedback
        unitState.lowPassCutoff = lowPassCutoff
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
