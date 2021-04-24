import Foundation

class PitchUnitState: FXUnitState<PitchPresetState> {
    
    let pitch: Float?
    let overlap: Float?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.pitch = map.floatValue(forKey: "pitch")
        self.overlap = map.floatValue(forKey: "overlap")
    }
}

class PitchPresetState: EffectsUnitPresetState {
    
    let pitch: Float
    let overlap: Float?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        guard let pitch = map.floatValue(forKey: "pitch") else {return nil}
        
        self.pitch = pitch
        self.overlap = map.floatValue(forKey: "overlap")
    }
}
