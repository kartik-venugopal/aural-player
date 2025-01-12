//
//  LegacyAudioGraphPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AVFoundation

struct LegacyAudioGraphPersistentState: Codable {

    let outputDevice: AudioDevicePersistentState?
    
    let volume: Float?
    let muted: Bool?
    let pan: Float?
    
    let masterUnit: LegacyMasterUnitPersistentState?
    let eqUnit: LegacyEQUnitPersistentState?
    let pitchUnit: LegacyPitchShiftUnitPersistentState?
    let timeUnit: LegacyTimeStretchUnitPersistentState?
    let reverbUnit: LegacyReverbUnitPersistentState?
    let delayUnit: LegacyDelayUnitPersistentState?
    let filterUnit: LegacyFilterUnitPersistentState?
    let audioUnits: [LegacyAudioUnitPersistentState]?
    
    let soundProfiles: [LegacySoundProfilePersistentState]?
    
    let audioUnitPresets: LegacyAudioUnitPresetsPersistentState?
}

enum LegacyEffectsUnitState: String, CaseIterable, Codable {
    
    // Master unit on, and effects unit on
    case active
    
    // Effects unit off
    case bypassed
    
    // Master unit off, and effects unit on
    case suppressed
}

struct LegacyMasterUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyMasterPresetPersistentState]?
    let currentPresetName: String?
}

struct LegacyMasterPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    
    let eq: LegacyEQPresetPersistentState?
    let pitch: LegacyPitchShiftPresetPersistentState?
    let time: LegacyTimeStretchPresetPersistentState?
    let reverb: LegacyReverbPresetPersistentState?
    let delay: LegacyDelayPresetPersistentState?
    let filter: LegacyFilterPresetPersistentState?
    
    let nameOfCurrentMasterPreset: String?
    let nameOfCurrentEQPreset: String?
    let nameOfCurrentPitchShiftPreset: String?
    let nameOfCurrentTimeStretchPreset: String?
    let nameOfCurrentReverbPreset: String?
    let nameOfCurrentDelayPreset: String?
    let nameOfCurrentFilterPreset: String?
}

struct LegacyEQUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyEQPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let globalGain: Float?
    let bands: [Float]?
}

struct LegacyEQPresetPersistentState: Codable {

    let name: String?
    let state: LegacyEffectsUnitState?
    
    let bands: [Float]?
    let globalGain: Float?
}

struct LegacyPitchShiftUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyPitchShiftPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let pitch: Float?
}

struct LegacyPitchShiftPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    let pitch: Float?
}

struct LegacyTimeStretchUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyTimeStretchPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let rate: Float?
    let shiftPitch: Bool?
}

struct LegacyTimeStretchPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    
    let rate: Float?
    let shiftPitch: Bool?
}

struct LegacyReverbUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyReverbPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let space: ReverbSpace?
    let amount: Float?
}

struct LegacyReverbPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    
    let space: ReverbSpace?
    let amount: Float?
}

struct LegacyDelayUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyDelayPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let amount: Float?
    let time: Double?
    let feedback: Float?
    let lowPassCutoff: Float?
}

struct LegacyDelayPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    
    let amount: Float?
    let time: Double?
    let feedback: Float?
    let lowPassCutoff: Float?
}

struct LegacyFilterUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let userPresets: [LegacyFilterPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let bands: [LegacyFilterBandPersistentState]?
}

struct LegacyFilterBandPersistentState: Codable {
    
    let type: FilterBandType?
    
    let minFreq: Float?     // Used for highPass, bandPass, and bandStop
    let maxFreq: Float?
}

struct LegacyFilterPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    let bands: [LegacyFilterBandPersistentState]?
}

struct LegacyAudioUnitPersistentState: Codable {
    
    let state: LegacyEffectsUnitState?
    let renderQuality: Int?

    let componentType: OSType?
    let componentSubType: OSType?
    let params: [LegacyAudioUnitParameterPersistentState]?
}

struct LegacyAudioUnitParameterPersistentState: Codable {
    
    let address: UInt64?
    let value: Float?
}

struct LegacyAudioUnitPresetPersistentState: Codable {
    
    let name: String?
    let state: LegacyEffectsUnitState?
    
    let componentType: OSType?
    let componentSubType: OSType?
    
    let parameterValues: [AUParameterAddress: Float]?
}

struct LegacyAudioUnitPresetsPersistentState: Codable {
    
    let presets: [OSType: [OSType: [LegacyAudioUnitPresetPersistentState]]]?
}

struct LegacySoundProfilePersistentState: Codable {
    
    let file: URLPath?
    
    let volume: Float?
    let pan: Float?
    let effects: LegacyMasterPresetPersistentState?
}
