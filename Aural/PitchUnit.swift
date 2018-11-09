import Foundation
import AVFoundation

class PitchUnit: FXUnit, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchPresets = PitchPresets()
    
    override var state: EffectsUnitState {
        didSet {node.bypass = state != .active}
    }
    
    // TODO: Pass in PitchUnitState (use generics to pass in type T)
    init(_ appState: AudioGraphState) {
        
        self.presets.addPresets(appState.pitchUnitState.userPresets)
        super.init(.pitch, appState.pitchUnitState.unitState)
        
        node.pitch = appState.pitchUnitState.pitch
        node.overlap = appState.pitchUnitState.overlap
    }
    
    var avNodes: [AVAudioNode] {return [node]}
    
    var pitch: Float {
        
        get {return node.pitch}
        
        set(newValue) {node.pitch = newValue}
    }
    
    var overlap: Float {
        
        get {return node.overlap}
        
        set(newValue) {node.overlap = newValue}
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(PitchPreset(presetName, .active, pitch, overlap, false))
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.presetByName(presetName) {
            pitch = preset.pitch
            overlap = preset.overlap
        }
    }
    
    func getSettingsAsPreset() -> PitchPreset {
        return PitchPreset("pitchSettings", state, pitch, overlap, false)
    }
    
    func persistentState() -> PitchUnitState {
        
        let unitState = PitchUnitState()
        
        unitState.unitState = state
        unitState.pitch = pitch
        unitState.overlap = overlap
        unitState.userPresets = presets.userDefinedPresets
        
        return unitState
    }
}
