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

class AudioUnitPresets: FXPresets<AudioUnitPreset> {
    
    init() {
        super.init(systemDefinedPresets: [], userDefinedPresets: [])
    }
    
    init(persistentState: AudioUnitPersistentState?) {
        
        let userDefinedPresets = (persistentState?.userPresets ?? []).map {AudioUnitPreset(persistentState: $0)}
        super.init(systemDefinedPresets: [], userDefinedPresets: userDefinedPresets)
    }
}

class AudioUnitPreset: FXUnitPreset {
    
    var componentType: OSType
    var componentSubType: OSType
    
    var number: Int
    
    init(_ name: String, _ state: FXUnitState, _ systemDefined: Bool, componentType: OSType, componentSubType: OSType, number: Int) {
        
        self.componentType = componentType
        self.componentSubType = componentSubType
        self.number = number
        
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: AudioUnitPresetPersistentState) {
        
        self.componentType = persistentState.componentType
        self.componentSubType = persistentState.componentSubType
        self.number = persistentState.number
        
        super.init(persistentState.name, persistentState.state, false)
    }
}

struct AudioUnitFactoryPreset {
    
    let name: String
    let number: Int
}
