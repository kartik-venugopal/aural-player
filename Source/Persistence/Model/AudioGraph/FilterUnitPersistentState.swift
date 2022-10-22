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

///
/// Persistent state for the Filter effects unit.
///
/// - SeeAlso:  `FilterUnit`
///
struct FilterUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [FilterPresetPersistentState]?
    let renderQuality: Int?
    
    let bands: [FilterBandPersistentState]?
}

///
/// Persistent state for a single Filter effects unit band.
///
/// - SeeAlso:  `FilterBand`
///
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

///
/// Persistent state for a single Filter effects unit preset.
///
/// - SeeAlso:  `FilterPreset`
///
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
