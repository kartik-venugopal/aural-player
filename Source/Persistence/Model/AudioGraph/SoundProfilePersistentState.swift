//
//  SoundProfilePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for a single sound profile.
///
/// - SeeAlso:  `SoundProfile`
///
struct SoundProfilePersistentState: Codable {
    
    let file: URLPath?
    
    let volume: Float?
    let pan: Float?
    let effects: MasterPresetPersistentState?
    
    let nameOfCurrentMasterPreset: String?
    let nameOfCurrentEQPreset: String?
    let nameOfCurrentPitchShiftPreset: String?
    let nameOfCurrentTimeStretchPreset: String?
    let nameOfCurrentReverbPreset: String?
    let nameOfCurrentDelayPreset: String?
    let nameOfCurrentFilterPreset: String?
    
    init(profile: SoundProfile) {
        
        self.file = profile.file.path
        self.volume = profile.volume
        self.pan = profile.pan
        self.effects = MasterPresetPersistentState(preset: profile.effects)
        
        self.nameOfCurrentMasterPreset = profile.nameOfCurrentMasterPreset
        self.nameOfCurrentEQPreset = profile.nameOfCurrentEQPreset
        self.nameOfCurrentPitchShiftPreset = profile.nameOfCurrentPitchShiftPreset
        self.nameOfCurrentTimeStretchPreset = profile.nameOfCurrentTimeStretchPreset
        self.nameOfCurrentReverbPreset = profile.nameOfCurrentReverbPreset
        self.nameOfCurrentDelayPreset = profile.nameOfCurrentDelayPreset
        self.nameOfCurrentFilterPreset = profile.nameOfCurrentFilterPreset
    }
}
