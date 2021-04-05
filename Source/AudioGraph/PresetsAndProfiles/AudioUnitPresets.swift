import Foundation
import AVFoundation

class AudioUnitPresets: FXPresets<AudioUnitPreset> {
}

class AudioUnitPreset: EffectsUnitPreset {
    
    // AUParameter identifier -> AUValue (aka Float)
    var params: [AUParameterAddress: Float]
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool, params: [AUParameterAddress: Float]) {
        
        self.params = params
        super.init(name, state, systemDefined)
    }
}

struct AudioUnitFactoryPreset {
    
    let name: String
    let number: Int
}
