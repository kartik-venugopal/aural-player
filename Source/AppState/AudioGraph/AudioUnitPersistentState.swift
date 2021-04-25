import Foundation

class AudioUnitState: FXUnitState<AudioUnitPresetState> {
    
    let componentType: OSType
    let componentSubType: OSType
    let params: [AudioUnitParameterState]
    
    init(componentType: OSType, componentSubType: OSType, params: [AudioUnitParameterState], state: EffectsUnitState, userPresets: [AudioUnitPresetState]) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.params = params
        
        super.init()
        self.state = state
        self.userPresets = userPresets
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let componentType = map.uint32Value(forKey: "componentType"),
              let componentSubType = map.uint32Value(forKey: "componentSubType") else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.params = map.arrayValue(forKey: "params", ofType: AudioUnitParameterState.self) ?? []
        
        super.init(map)
    }
}

class AudioUnitParameterState: PersistentStateProtocol {
    
    let address: UInt64
    let value: Float
    
    init(address: UInt64, value: Float) {
        
        self.address = address
        self.value = value
    }
    
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
    
    init(preset: AudioUnitPreset) {
        
        self.componentType = preset.componentType
        self.componentSubType = preset.componentSubType
        self.number = preset.number
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let componentType = map.uint32Value(forKey: "componentType"),
              let componentSubType = map.uint32Value(forKey: "componentSubType"),
              let number = map.intValue(forKey: "number") else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.number = number
        
        super.init(map)
    }
}
