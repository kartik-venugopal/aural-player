import Foundation

class TimeUnitState: FXUnitState<TimePresetState> {
    
    let rate: Float?
    let shiftPitch: Bool?
    let overlap: Float?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.rate = map.floatValue(forKey: "rate")
        self.overlap = map.floatValue(forKey: "overlap")
        self.shiftPitch = map.boolValue(forKey: "shiftPitch")
    }
}

class TimePresetState: EffectsUnitPresetState {
    
    let rate: Float
    let overlap: Float?
    let shiftPitch: Bool?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        guard let rate = map.floatValue(forKey: "rate") else {return nil}
        
        self.rate = rate
        self.overlap = map.floatValue(forKey: "overlap")
        self.shiftPitch = map.boolValue(forKey: "shiftPitch")
    }
}
