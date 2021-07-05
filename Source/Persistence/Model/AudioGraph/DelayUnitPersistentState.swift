//
//  DelayUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct DelayUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [DelayPresetPersistentState]?
    
    let amount: Float?
    let time: Double?
    let feedback: Float?
    let lowPassCutoff: Float?
}

struct DelayPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let amount: Float?
    let time: Double?
    let feedback: Float?
    let lowPassCutoff: Float?
    
    init(preset: DelayPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.amount = preset.amount
        self.time = preset.time
        self.feedback = preset.feedback
        self.lowPassCutoff = preset.lowPassCutoff
    }
}
