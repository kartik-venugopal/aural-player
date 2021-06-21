import AVFoundation

class TimeUnit: FXUnit, TimeUnitProtocol {
    
    private let node: VariableRateNode = VariableRateNode()
    let presets: TimePresets = TimePresets()
    
    init(_ persistentState: AudioGraphState) {
        
        let timeState = persistentState.timeUnit
        
        super.init(.time, timeState.state)
        
        rate = timeState.rate
        overlap = timeState.overlap
        shiftPitch = timeState.shiftPitch
        
        presets.addPresets(timeState.userPresets)
    }
    
    override var avNodes: [AVAudioNode] {return [node.timePitchNode, node.variNode]}

    var rate: Float {
        
        get {node.rate}
        set {node.rate = newValue}
    }
    
    var overlap: Float {
        
        get {node.overlap}
        set {node.overlap = newValue}
    }
    
    var shiftPitch: Bool {
        
        get {node.shiftPitch}
        set {node.shiftPitch = newValue}
    }
    
    var pitch: Float {
        return node.pitch
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(TimePreset(presetName, .active, node.rate, node.overlap, node.shiftPitch, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: TimePreset) {
        
        rate = preset.rate
        overlap = preset.overlap
        shiftPitch = preset.shiftPitch
    }
    
    var settingsAsPreset: TimePreset {
        return TimePreset("timeSettings", state, rate, overlap, shiftPitch, false)
    }
    
    var persistentState: TimeUnitState {

        let unitState = TimeUnitState()

        unitState.state = state
        unitState.rate = rate
        unitState.overlap = overlap
        unitState.shiftPitch = shiftPitch
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
