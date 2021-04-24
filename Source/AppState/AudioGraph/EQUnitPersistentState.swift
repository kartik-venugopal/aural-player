import Foundation

class EQUnitState: FXUnitState<EQPresetState> {
    
    let type: EQType?
    let globalGain: Float?
    let bands: [Float]?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.type = map.enumValue(forKey: "type", ofType: EQType.self)
        self.bands = map.floatArray(forKey: "bands")
        self.globalGain = map.floatValue(forKey: "globalGain")
    }
}

class EQPresetState: EffectsUnitPresetState {
    
    let bands: [Float]
    let globalGain: Float?
    
    required init?(_ map: NSDictionary) {

        super.init(map)
        
        guard let bands = map.floatArray(forKey: "bands") else {return nil}
        
        self.bands = bands
        self.globalGain = map.floatValue(forKey: "globalGain")
    }
}
