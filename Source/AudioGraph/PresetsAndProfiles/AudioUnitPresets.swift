//
//  AudioUnitPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import AVFoundation

class AudioUnitPresetsMap: PersistentModelObject {
    
    let map: CompositeKeyMap<OSType, AudioUnitPresets> = CompositeKeyMap()
    
    init(persistentState: AudioUnitPresetsPersistentState?) {
     
        for (type, mapForType) in persistentState?.presets ?? [:] {
            
            for (subType, presetsState) in mapForType {
                
                let presets = AudioUnitPresets(componentType: type, componentSubType: subType, persistentState: presetsState)
                map[type, subType] = presets
            }
        }
    }
    
    func getPresetsForAU(componentType: OSType, componentSubType: OSType) -> AudioUnitPresets {
        
        if let presets = map[componentType, componentSubType] {
            return presets
        } else {
            
            let presets = AudioUnitPresets(componentType: componentType, componentSubType: componentSubType)
            map[componentType, componentSubType] = presets
            return presets
        }
    }
    
    var persistentState: AudioUnitPresetsPersistentState {
        
        var map: [OSType: [OSType: [AudioUnitPresetPersistentState]]] = [:]
        
        for (type, subType, presets) in self.map.entries {
            
            if map[type] == nil {
                map[type] = [:]
            }
            
            map[type]?[subType] = presets.userDefinedObjects.map {AudioUnitPresetPersistentState(preset: $0)}
        }
        
        return AudioUnitPresetsPersistentState(presets: map)
    }
}

///
/// Manages a mapped collection of presets that can be applied to a hosted AU effects unit.
///
class AudioUnitPresets: EffectsUnitPresets<AudioUnitPreset> {
    
    var componentType: OSType
    var componentSubType: OSType
    
    init(componentType: OSType, componentSubType: OSType) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        
        super.init(systemDefinedObjects: [], userDefinedObjects: [])
    }
    
    init(componentType: OSType, componentSubType: OSType, persistentState: [AudioUnitPresetPersistentState]?) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        
        let userDefinedPresets = (persistentState ?? []).compactMap {AudioUnitPreset(persistentState: $0)}
        super.init(systemDefinedObjects: [], userDefinedObjects: userDefinedPresets)
    }
}

///
/// Represents a single hosted AU effects unit preset.
///
class AudioUnitPreset: EffectsUnitPreset {
    
    var componentType: OSType
    var componentSubType: OSType
    
    var parameterValues: [AUParameterAddress: Float]
    
    init(name: String, state: EffectsUnitState, systemDefined: Bool,
         componentType: OSType, componentSubType: OSType,
         parameterValues: [AUParameterAddress: Float]) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.parameterValues = parameterValues
        
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: AudioUnitPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let componentType = persistentState.componentType,
              let componentSubType = persistentState.componentSubType,
              let parameterValues = persistentState.parameterValues
        else {return nil}
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.parameterValues = parameterValues
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
}

///
/// Represents a single factory preset provided by an AU plug-in.
///
struct AudioUnitFactoryPreset {
    
    let name: String
    let number: Int
}
