import Foundation
import AVFoundation

class PitchUnit: FXUnit, FXUnitPresetsProtocol, PitchShiftUnitProtocol {
    
    private let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchPresets = PitchPresets()
    
    init(_ appState: AudioGraphState) {
        
        super.init(.pitch, appState.pitchState)
        
        node.bypass = state != .active
        node.pitch = appState.pitch
        node.overlap = appState.pitchOverlap
        presets.addPresets(appState.pitchUserPresets)
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
    
    func savePreset(_ presetName: String) {
        presets.addPreset(PitchPreset(presetName, .active, pitch, overlap, false))
    }
    
    func applyPreset(_ preset: PitchPreset) {
        
        pitch = preset.pitch
        overlap = preset.overlap
    }
}
