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

///
/// Persistent state for the Time Stretch effects unit.
///
/// - SeeAlso:  `TimeStretchUnit`
///
struct TimeStretchUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [TimeStretchPresetPersistentState]?
    let renderQuality: Int?
    
    let rate: Float?
    let shiftPitch: Bool?
}

///
/// Persistent state for a single Time Stretch effects unit preset.
///
/// - SeeAlso:  `TimeStretchPreset`
///
struct TimeStretchPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let rate: Float?
    let shiftPitch: Bool?
    
    init(preset: TimeStretchPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.rate = preset.rate
        self.shiftPitch = preset.shiftPitch
    }
}
