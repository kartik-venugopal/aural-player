import Foundation

class FilterUnitState: FXUnitState<FilterPresetState> {
    
    let bands: [FilterBandState]?
    
    required init?(_ map: NSDictionary) {

        super.init(map)
        
        self.bands = map.arrayValue(forKey: "bands", ofType: FilterBandState.self)
    }
}

class FilterBandState: PersistentStateProtocol {
    
    let type: FilterBandType
    
    let minFreq: Float?     // Used for highPass, bandPass, and bandStop
    let maxFreq: Float?
    
    required init?(_ map: NSDictionary) {
        
        guard let type = map.enumValue(forKey: "type", ofType: FilterBandType.self) else {return nil}
        self.type = type
        
        let minFreq = map.floatValue(forKey: "minFreq")
        let maxFreq = map.floatValue(forKey: "maxFreq")
        
        switch type {
        
        case .bandPass, .bandStop:
            
            guard let theMinFreq = minFreq, let theMaxFreq = maxFreq else {return nil}
            self.minFreq = theMinFreq
            self.maxFreq = theMaxFreq
            
        case .lowPass:
            
            if maxFreq == nil {return nil}
            self.maxFreq = maxFreq
            
        case .highPass:
            
            if minFreq == nil {return  nil}
            self.minFreq = minFreq
        }
    }
}

class FilterPresetState: EffectsUnitPresetState {
    
    let bands: [FilterBandState]
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        guard let bands = map.arrayValue(forKey: "bands", ofType: FilterBandState.self) else {return nil}
        self.bands = bands
    }
}

//fileprivate func deserializeFilterPreset(_ map: NSDictionary) -> FilterPreset {
//
//    let name = map["name"] as? String ?? ""
//    let state = mapEnum(map, "state", AppDefaults.filterState)
//
//    let presetBands: [FilterBand] = []
//    if let bands = map["bands"] as? [NSDictionary] {
//
//        for bandDict in bands {
//
//            let bandType: FilterBandType = mapEnum(bandDict, "type", AppDefaults.filterBandType)
//            let bandMinFreq: Float? = mapNumeric(bandDict, "minFreq")
//            let bandMaxFreq: Float? = mapNumeric(bandDict, "maxFreq")
//
//            presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
//        }
//    }
//
//    return FilterPreset(name, state, presetBands, false)
//}
