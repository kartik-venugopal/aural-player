import AVFoundation

class PitchUnit: FXUnit, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchPresets = PitchPresets()
    
    // TODO: Pass in PitchUnitState (use generics to pass in type T)
    init(_ persistentState: AudioGraphState) {
        
        super.init(.pitch, persistentState.pitchUnit.state)
        
        node.pitch = persistentState.pitchUnit.pitch
        node.overlap = persistentState.pitchUnit.overlap
        
        presets.addPresets(persistentState.pitchUnit.userPresets)
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
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}
