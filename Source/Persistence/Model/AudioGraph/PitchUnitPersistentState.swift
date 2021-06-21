import Foundation

class PitchUnitPersistentState: FXUnitPersistentState<PitchPresetPersistentState> {
    
    var pitch: Float?
    var overlap: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.pitch = map["pitch", Float.self]
        self.overlap = map["overlap", Float.self]
    }
}

class PitchPresetPersistentState: EffectsUnitPresetPersistentState {
    
    let pitch: Float
    let overlap: Float?
    
    init(preset: PitchPreset) {
        
        self.pitch = preset.pitch
        self.overlap = preset.overlap
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let pitch = map["pitch", Float.self] else {return nil}
        
        self.pitch = pitch
        self.overlap = map["overlap", Float.self]
        
        super.init(map)
    }
}
