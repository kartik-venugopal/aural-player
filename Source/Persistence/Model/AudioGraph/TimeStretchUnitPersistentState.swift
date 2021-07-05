//
//  TimeStretchUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct TimeStretchUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [TimeStretchPresetPersistentState]?
    
    let rate: Float?
    let shiftPitch: Bool?
    let overlap: Float?
}

struct TimeStretchPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let rate: Float?
    let overlap: Float?
    let shiftPitch: Bool?
    
    init(preset: TimePreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.rate = preset.rate
        self.overlap = preset.overlap
        self.shiftPitch = preset.shiftPitch
    }
}
