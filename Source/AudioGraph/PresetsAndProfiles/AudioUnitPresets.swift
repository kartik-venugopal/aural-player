import Foundation
import AVFoundation

class AudioUnitPresets: FXPresets<AudioUnitPreset> {
}

class AudioUnitPreset: EffectsUnitPreset {
    
    var componentType: OSType
    var componentSubType: OSType
    
    var number: Int
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool, componentType: OSType, componentSubType: OSType, number: Int) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.number = number
        
        super.init(name, state, systemDefined)
    }
}

struct AudioUnitFactoryPreset {
    
    let name: String
    let number: Int
}
