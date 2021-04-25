import Foundation

class EQUnitState: FXUnitState<EQPresetState> {
    
    var type: EQType?
    var globalGain: Float?
    var bands: [Float]?
    
    override init() {super.init()}
    
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
    
    init(preset: EQPreset) {
        
        self.bands = preset.bands
        self.globalGain = preset.globalGain
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {

        guard let bands = map.floatArray(forKey: "bands") else {return nil}
        
        self.bands = bands
        self.globalGain = map.floatValue(forKey: "globalGain")
        
        super.init(map)
    }
}
