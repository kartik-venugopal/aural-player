import Foundation

class AudioUnitState: FXUnitState<AudioUnitPresetState> {
    
    let componentType: OSType?
    let componentSubType: OSType?
    let params: [AudioUnitParameterState]?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        guard let componentType = map.uint32Value(forKey: "componentType"),
              let componentSubType = map.uint32Value(forKey: "componentSubType") else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.params = map.arrayValue(forKey: "params", ofType: AudioUnitParameterState.self)
    }
}

class AudioUnitParameterState: PersistentStateProtocol {
    
    let address: UInt64
    let value: Float
    
    required init?(_ map: NSDictionary) {
        
        guard let address = map.uint64Value(forKey: "address"),
              let value = map.floatValue(forKey: "value") else {return nil}
        
        self.address = address
        self.value = value
    }
}

class AudioUnitPresetState: EffectsUnitPresetState {
    
    let componentType: OSType
    let componentSubType: OSType
    let number: Int
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        guard let componentType = map.uint32Value(forKey: "componentType"),
              let componentSubType = map.uint32Value(forKey: "componentSubType"),
              let number = map.intValue(forKey: "number") else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.number = number
    }
}
