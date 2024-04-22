//
//  AudioUnitPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import AudioToolbox

///
/// Persistent state for an effects unit that hosts an Audio Units (AU) plug-in.
///
/// - SeeAlso:  `HostedAudioUnit`
///
struct AudioUnitPersistentState: Codable {
    
    let state: EffectsUnitState?

    let componentType: OSType?
    let componentSubType: OSType?
    let params: [AudioUnitParameterPersistentState]?
    
    init(state: EffectsUnitState?, componentType: OSType?, componentSubType: OSType?, params: [AudioUnitParameterPersistentState]?) {
        
        self.state = state
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.params = params
    }
    
    init(legacyPersistentState: LegacyAudioUnitPersistentState) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState.state)
        
        self.componentType = legacyPersistentState.componentType
        self.componentSubType = legacyPersistentState.componentSubType
        self.params = legacyPersistentState.params?.map {AudioUnitParameterPersistentState(legacyPersistentState: $0)}
    }
}

///
/// Persistent state for a single Hosted Audio Unit effects parameter.
///
struct AudioUnitParameterPersistentState: Codable {
    
    let address: UInt64?
    let value: Float?
    
    init(address: UInt64?, value: Float?) {
        
        self.address = address
        self.value = value
    }
    
    init(legacyPersistentState: LegacyAudioUnitParameterPersistentState) {
        
        self.address = legacyPersistentState.address
        self.value = legacyPersistentState.value
    }
}

///
/// Persistent state for a single Hosted Audio Unit effects preset.
///
/// - SeeAlso:  `AudioUnitPreset`
///
struct AudioUnitPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let componentType: OSType?
    let componentSubType: OSType?
    
    let parameterValues: [AUParameterAddress: Float]?
    
    init(preset: AudioUnitPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.componentType = preset.componentType
        self.componentSubType = preset.componentSubType
        
        self.parameterValues = preset.parameterValues
    }
    
    init(legacyPersistentState: LegacyAudioUnitPresetPersistentState) {
        
        self.name = legacyPersistentState.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState.state)
        self.componentType = legacyPersistentState.componentType
        self.componentSubType = legacyPersistentState.componentSubType
        self.parameterValues = legacyPersistentState.parameterValues
    }
}

struct AudioUnitPresetsPersistentState: Codable {
    
    let presets: [OSType: [OSType: [AudioUnitPresetPersistentState]]]?
    
    init(presets: [OSType: [OSType: [AudioUnitPresetPersistentState]]]) {
        self.presets = presets
    }
    
    init(legacyPersistentState: LegacyAudioUnitPresetsPersistentState?) {
        
        var presetsMap: [OSType: [OSType: [AudioUnitPresetPersistentState]]] = [:]
        
        for (type, subTypeAndPresetsMap) in legacyPersistentState?.presets ?? [:] {
            
            presetsMap[type] = [:]
            
            for (subType, presets) in subTypeAndPresetsMap {
                presetsMap[type]?[subType] = presets.map {AudioUnitPresetPersistentState(legacyPersistentState: $0)}
            }
        }
        
        self.presets = presetsMap
    }
}
