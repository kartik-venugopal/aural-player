//
//  FilterUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct FilterUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [FilterPresetPersistentState]?
    
    let bands: [FilterBandPersistentState]?
}

struct FilterBandPersistentState: Codable {
    
    let type: FilterBandType?
    
    let minFreq: Float?     // Used for highPass, bandPass, and bandStop
    let maxFreq: Float?
    
    init(band: FilterBand) {
        
        self.type = band.type
        self.minFreq = band.minFreq
        self.maxFreq = band.maxFreq
    }
}

struct FilterPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let bands: [FilterBandPersistentState]?
    
    init(preset: FilterPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.bands = preset.bands.map {FilterBandPersistentState(band: $0)}
    }
}
