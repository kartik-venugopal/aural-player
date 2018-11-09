import AVFoundation

class TimeUnit: FXUnit, TimeUnitProtocol {
    
    override var state: EffectsUnitState {
        didSet {node.bypass = state != .active}
    }
    
    private let node: VariableRateNode = VariableRateNode()
    let presets: TimePresets = TimePresets()
    
    init(_ appState: AudioGraphState) {
        
        let timeState = appState.timeUnitState
        
        super.init(.time, timeState.unitState)
        node.bypass = state != .active
        
        rate = timeState.rate
        overlap = timeState.overlap
        shiftPitch = timeState.shiftPitch
        
        
        presets.addPresets(timeState.userPresets)
    }
    
    var avNodes: [AVAudioNode] {return [node.timePitchNode, node.variNode]}

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
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(TimePreset(presetName, .active, node.rate, node.overlap, node.shiftPitch, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            
            rate = preset.rate
            overlap = preset.overlap
            shiftPitch = preset.pitchShift
        }
    }
    
    func getSettingsAsPreset() -> TimePreset {
        return TimePreset("timeSettings", state, rate, overlap, shiftPitch, false)
    }
    
    func persistentState() -> TimeUnitState {

        let unitState = TimeUnitState()

        unitState.unitState = state
        unitState.rate = rate
        unitState.overlap = overlap
        unitState.shiftPitch = shiftPitch
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
