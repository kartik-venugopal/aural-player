import Foundation
import AVFoundation

class PitchUnit: FXUnit, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchPresets = PitchPresets()
    
    init(_ appState: AudioGraphState) {

        super.init(.pitch, appState.pitchState)
        
        node.bypass = state != .active
        node.pitch = appState.pitch
        node.overlap = appState.pitchOverlap
    }
    
    override func toggleState() -> EffectsUnitState {
        
        node.bypass = super.toggleState() != .active
        return state
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
}
