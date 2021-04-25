import Foundation

class AudioUnitPersistentState: FXUnitPersistentState<AudioUnitPresetPersistentState> {
    
    let componentType: OSType
    let componentSubType: OSType
    let params: [AudioUnitParameterPersistentState]
    
    init(componentType: OSType, componentSubType: OSType, params: [AudioUnitParameterPersistentState], state: EffectsUnitState, userPresets: [AudioUnitPresetPersistentState]) {
        
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
        self.params = map.arrayValue(forKey: "params", ofType: AudioUnitParameterPersistentState.self) ?? []
        
        super.init(map)
    }
}

class AudioUnitParameterPersistentState: PersistentStateProtocol {
    
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

class AudioUnitPresetPersistentState: EffectsUnitPresetPersistentState {
    
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
