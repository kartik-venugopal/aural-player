import AVFoundation

class TimeUnit: FXUnit, TimeUnitProtocol {
    
    private let node: VariableRateNode = VariableRateNode()
    let presets: TimePresets = TimePresets()
    
    init(persistentState: TimeUnitState?) {
        
        super.init(.time, persistentState?.state ?? AudioGraphDefaults.timeState)
        
        rate = persistentState?.rate ?? AudioGraphDefaults.timeStretchRate
        overlap = persistentState?.overlap ?? AudioGraphDefaults.timeOverlap
        shiftPitch = persistentState?.shiftPitch ?? AudioGraphDefaults.timeShiftPitch
        
        presets.addPresets((persistentState?.userPresets ?? []).map {TimePreset(persistentState: $0)})
    }
    
    override var avNodes: [AVAudioNode] {return [node.timePitchNode, node.variNode]}

    var rate: Float {
        
        get {return node.rate}
        set(newValue) {node.rate = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        set(newValue) {node.overlap = newValue}
    }
    
    var shiftPitch: Bool {
        
        get {return node.shiftPitch}
        set(newValue) {node.shiftPitch = newValue}
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
        unitState.userPresets = presets.userDefinedPresets.map {TimePresetState(preset: $0)}

        return unitState
    }
}
