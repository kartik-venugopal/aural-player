//
//  PitchUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class PitchUnitPersistentState: EffectsUnitPersistentState<PitchPresetPersistentState> {
    
    var pitch: Float?
    var overlap: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.pitch = map.floatValue(forKey: "pitch")
        self.overlap = map.floatValue(forKey: "overlap")
    }
}

class PitchPresetPersistentState: EffectsUnitPresetPersistentState {
    
    let pitch: Float
    let overlap: Float?
    
    init(preset: PitchPreset) {
        
        self.pitch = preset.pitch
        self.overlap = preset.overlap
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let pitch = map.floatValue(forKey: "pitch") else {return nil}
        
        self.pitch = pitch
        self.overlap = map.floatValue(forKey: "overlap")
        
        super.init(map)
    }
}
