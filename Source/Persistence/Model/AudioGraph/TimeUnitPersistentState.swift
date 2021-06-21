import Foundation

class TimeUnitPersistentState: FXUnitPersistentState<TimePresetPersistentState> {
    
    var rate: Float?
    var shiftPitch: Bool?
    var overlap: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.rate = map["rate", Float.self]
        self.overlap = map["overlap", Float.self]
        self.shiftPitch = map["shiftPitch", Bool.self]
    }
}

class TimePresetPersistentState: EffectsUnitPresetPersistentState {
    
    let rate: Float
    let overlap: Float?
    let shiftPitch: Bool?
    
    init(preset: TimePreset) {
        
        self.rate = preset.rate
        self.overlap = preset.overlap
        self.shiftPitch = preset.shiftPitch
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let rate = map["rate", Float.self] else {return nil}
        
        self.rate = rate
        self.overlap = map["overlap", Float.self]
        self.shiftPitch = map["shiftPitch", Bool.self]
        
        super.init(map)
    }
}
