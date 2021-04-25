import Foundation

class FilterUnitPersistentState: FXUnitPersistentState<FilterPresetState> {
    
    var bands: [FilterBandPersistentState]?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {

        self.bands = map.arrayValue(forKey: "bands", ofType: FilterBandPersistentState.self)
        super.init(map)
    }
}

class FilterBandPersistentState: PersistentStateProtocol {
    
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

class FilterPresetState: EffectsUnitPresetPersistentState {
    
    let bands: [FilterBandPersistentState]
    
    init(preset: FilterPreset) {
        
        self.bands = preset.bands.map {FilterBandPersistentState(band: $0)}
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let bands = map.arrayValue(forKey: "bands", ofType: FilterBandPersistentState.self) else {return nil}
        self.bands = bands
        
        super.init(map)
    }
}
