import AVFoundation

class PitchUnit: FXUnit, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchPresets = PitchPresets()
    
    init(persistentState: PitchUnitState?) {
        
        super.init(.pitch, persistentState?.state ?? AudioGraphDefaults.pitchState)
        
        node.pitch = persistentState?.pitch ?? AudioGraphDefaults.pitch
        node.overlap = persistentState?.overlap ?? AudioGraphDefaults.pitchOverlap
        
        presets.addPresets((persistentState?.userPresets ?? []).map {PitchPreset(persistentState: $0)})
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    var pitch: Float {
        
        get {return node.pitch}
        set(newValue) {node.pitch = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        set(newValue) {node.overlap = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(PitchPreset(presetName, .active, pitch, overlap, false))
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: PitchPreset) {
        
        pitch = preset.pitch
        overlap = preset.overlap
    }
    
    var settingsAsPreset: PitchPreset {
        return PitchPreset("pitchSettings", state, pitch, overlap, false)
    }
    
    var persistentState: PitchUnitState {
        
        let unitState = PitchUnitState()
        
        unitState.state = state
        unitState.pitch = pitch
        unitState.overlap = overlap
        unitState.userPresets = presets.userDefinedPresets.map {PitchPresetState(preset: $0)}
        
        return unitState
    }
}
