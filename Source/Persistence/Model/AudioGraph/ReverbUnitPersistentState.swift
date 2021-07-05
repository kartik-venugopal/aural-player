//
//  ReverbUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct ReverbUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [ReverbPresetPersistentState]?
    
    let space: ReverbSpaces?
    let amount: Float?
}

struct ReverbPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let space: ReverbSpaces?
    let amount: Float?
    
    init(preset: ReverbPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.space = preset.space
        self.amount = preset.amount
    }
}
