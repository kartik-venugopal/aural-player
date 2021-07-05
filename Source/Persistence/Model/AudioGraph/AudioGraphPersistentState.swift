//
//  AudioGraphPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
 Encapsulates audio graph state
 */
struct AudioGraphPersistentState: Codable {
    
    let outputDevice: AudioDevicePersistentState?
    
    let volume: Float?
    let muted: Bool?
    let balance: Float?
    
    let masterUnit: MasterUnitPersistentState?
    let eqUnit: EQUnitPersistentState?
    let pitchUnit: PitchShiftUnitPersistentState?
    let timeUnit: TimeStretchUnitPersistentState?
    let reverbUnit: ReverbUnitPersistentState?
    let delayUnit: DelayUnitPersistentState?
    let filterUnit: FilterUnitPersistentState?
    let audioUnits: [AudioUnitPersistentState]?
    
    let soundProfiles: [SoundProfilePersistentState]?
}
