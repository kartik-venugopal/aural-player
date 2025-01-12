//
//  FilterUnitPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    let currentPresetName: String?
    let renderQuality: Int?
    
    let bands: [FilterBandPersistentState]?
    
    init(state: EffectsUnitState?, userPresets: [FilterPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, bands: [FilterBandPersistentState]?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        self.bands = bands
    }
    
    init(legacyPersistentState: LegacyFilterUnitPersistentState?) {
        
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.userPresets = legacyPersistentState?.userPresets?.map {FilterPresetPersistentState(legacyPersistentState: $0)}
        self.currentPresetName = legacyPersistentState?.currentPresetName
        self.renderQuality = legacyPersistentState?.renderQuality
        
        self.bands = legacyPersistentState?.bands?.map {FilterBandPersistentState(legacyPersistentState: $0)}
    }
}

///
/// Persistent state for a single Filter effects unit band.
///
/// - SeeAlso:  `FilterBand`
///
struct FilterBandPersistentState: Codable {
    
    let type: FilterBandType?
    
    let bypass: Bool?
    
    let minFreq: Float?     // Used for highPass, bandPass, and bandStop
    let maxFreq: Float?
    
    init(band: FilterBand) {
        
        self.type = band.type
        self.bypass = band.bypass
        self.minFreq = band.minFreq
        self.maxFreq = band.maxFreq
    }
    
    init(legacyPersistentState: LegacyFilterBandPersistentState) {
        
        self.type = legacyPersistentState.type
        self.bypass = false     // Legacy apps cannot bypass individual filter bands.
        self.minFreq = legacyPersistentState.minFreq
        self.maxFreq = legacyPersistentState.maxFreq
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
    
    init(legacyPersistentState: LegacyFilterPresetPersistentState?) {
        
        self.name = legacyPersistentState?.name
        self.state = EffectsUnitState.fromLegacyState(legacyPersistentState?.state)
        self.bands = legacyPersistentState?.bands?.map {FilterBandPersistentState(legacyPersistentState: $0)}
    }
}
