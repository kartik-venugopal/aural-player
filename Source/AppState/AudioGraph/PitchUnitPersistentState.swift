import Foundation

class PitchUnitState: FXUnitState<PitchPresetState> {
    
    var pitch: Float?
    var overlap: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.pitch = map.floatValue(forKey: "pitch")
        self.overlap = map.floatValue(forKey: "overlap")
    }
}

class PitchPresetState: EffectsUnitPresetState {
    
    let pitch: Float
    let overlap: Float?
    
    init(preset: PitchPreset) {
        
        self.pitch = preset.pitch
        self.overlap = preset.overlap
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let pitch = map.floatValue(forKey: "pitch") else {return nil}
        
        self.pitch = pitch
        self.overlap = map.floatValue(forKey: "overlap")
        
        super.init(map)
    }
}
