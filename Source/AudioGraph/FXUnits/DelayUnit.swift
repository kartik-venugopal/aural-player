import AVFoundation

class DelayUnit: FXUnit, DelayUnitProtocol {
    
    private let node: AVAudioUnitDelay = AVAudioUnitDelay()
    let presets: DelayPresets = DelayPresets()
    
    init(persistentState: DelayUnitPersistentState?) {
        
        super.init(.delay, persistentState?.state ?? AudioGraphDefaults.delayState)
        
        time = persistentState?.time ?? AudioGraphDefaults.delayTime
        amount = persistentState?.amount ?? AudioGraphDefaults.delayAmount
        feedback = persistentState?.feedback ?? AudioGraphDefaults.delayFeedback
        lowPassCutoff = persistentState?.lowPassCutoff ?? AudioGraphDefaults.delayLowPassCutoff
        
        presets.addPresets((persistentState?.userPresets ?? []).map {DelayPreset(persistentState: $0)})
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
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
    
    var persistentState: DelayUnitPersistentState {

        let unitState = DelayUnitPersistentState()

        unitState.state = state
        unitState.time = time
        unitState.amount = amount
        unitState.feedback = feedback
        unitState.lowPassCutoff = lowPassCutoff
        unitState.userPresets = presets.userDefinedPresets.map {DelayPresetPersistentState(preset: $0)}

        return unitState
    }
}
