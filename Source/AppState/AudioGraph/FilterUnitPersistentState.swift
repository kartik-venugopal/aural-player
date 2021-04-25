import Foundation

class FilterUnitState: FXUnitState<FilterPresetState> {
    
    var bands: [FilterBandState]?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {

        self.bands = map.arrayValue(forKey: "bands", ofType: FilterBandState.self)
        super.init(map)
    }
}

class FilterBandState: PersistentStateProtocol {
    
    let type: FilterBandType
    
    let minFreq: Float?     // Used for highPass, bandPass, and bandStop
    let maxFreq: Float?
    
    init(band: FilterBand) {
        
        self.type = band.type
        self.minFreq = band.minFreq
        self.maxFreq = band.maxFreq
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let type = map.enumValue(forKey: "type", ofType: FilterBandType.self) else {return nil}
        self.type = type
        
        self.minFreq = map.floatValue(forKey: "minFreq")
        self.maxFreq = map.floatValue(forKey: "maxFreq")
        
        switch type {
        
        case .bandPass, .bandStop:
            
            guard self.minFreq != nil && self.maxFreq != nil else {return nil}
            
        case .lowPass:
            
            if maxFreq == nil {return nil}
            
        case .highPass:
            
            if minFreq == nil {return  nil}
        }
    }
}

class FilterPresetState: EffectsUnitPresetState {
    
    let bands: [FilterBandState]
    
    init(preset: FilterPreset) {
        
        self.bands = preset.bands.map {FilterBandState(band: $0)}
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let bands = map.arrayValue(forKey: "bands", ofType: FilterBandState.self) else {return nil}
        self.bands = bands
        
        super.init(map)
    }
}
