//
//  AudioUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class AudioUnitPersistentState: FXUnitPersistentState<AudioUnitPresetPersistentState> {
    
    let componentType: OSType
    let componentSubType: OSType
    let params: [AudioUnitParameterPersistentState]
    
    init(componentType: OSType, componentSubType: OSType, params: [AudioUnitParameterPersistentState], state: FXUnitState, userPresets: [AudioUnitPresetPersistentState]) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.params = params
        
        super.init()
        self.state = state
        self.userPresets = userPresets
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let componentType = map["componentType", UInt32.self],
              let componentSubType = map["componentSubType", UInt32.self] else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.params = map.persistentObjectArrayValue(forKey: "params", ofType: AudioUnitParameterPersistentState.self) ?? []
        
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
        
        guard let address = map["address", UInt64.self],
              let value = map["value", Float.self] else {return nil}
        
        self.address = address
        self.value = value
    }
}

class AudioUnitPresetPersistentState: FXUnitPresetPersistentState {
    
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
        
        guard let componentType = map["componentType", UInt32.self],
              let componentSubType = map["componentSubType", UInt32.self],
              let number = map["number", Int.self] else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.number = number
        
        super.init(map)
    }
}
