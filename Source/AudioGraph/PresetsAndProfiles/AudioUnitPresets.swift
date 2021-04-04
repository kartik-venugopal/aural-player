import Foundation

class AudioUnitPresets: FXPresets<AudioUnitPreset> {
}

class AudioUnitPreset: EffectsUnitPreset {
    
    // AUParameter identifier -> AUValue (aka Float)
    var params: [String: Float]
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool, params: [String: Float]) {
        
        self.params = params
        super.init(name, state, systemDefined)
    }
}
