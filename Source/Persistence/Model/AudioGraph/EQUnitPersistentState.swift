//
//  EQUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Equalizer effects unit.
///
/// - SeeAlso:  `EQUnit`
///
struct EQUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [EQPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let globalGain: Float?
    let bands: [Float]?
}

///
/// Persistent state for a single Equalizer effects unit preset.
///
/// - SeeAlso:  `EQPreset`
///
struct EQPresetPersistentState: Codable {

    let name: String?
    let state: EffectsUnitState?
    
    let bands: [Float]?
    let globalGain: Float?
    
    init(preset: EQPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.bands = preset.bands
        self.globalGain = preset.globalGain
    }
}
