import Foundation
import AVFoundation

class AudioUnitPresets: FXPresets<AudioUnitPreset> {
}

class AudioUnitPreset: EffectsUnitPreset {
    
    var number: Int
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool, number: Int) {
        
        self.number = number
        super.init(name, state, systemDefined)
    }
}

struct AudioUnitFactoryPreset {
    
    let name: String
    let number: Int
}
