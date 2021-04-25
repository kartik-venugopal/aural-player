import Foundation

class TimeUnitPersistentState: FXUnitPersistentState<TimePresetPersistentState> {
    
    var rate: Float?
    var shiftPitch: Bool?
    var overlap: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.rate = map.floatValue(forKey: "rate")
        self.overlap = map.floatValue(forKey: "overlap")
        self.shiftPitch = map.boolValue(forKey: "shiftPitch")
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
        
        guard let rate = map.floatValue(forKey: "rate") else {return nil}
        
        self.rate = rate
        self.overlap = map.floatValue(forKey: "overlap")
        self.shiftPitch = map.boolValue(forKey: "shiftPitch")
        
        super.init(map)
    }
}
