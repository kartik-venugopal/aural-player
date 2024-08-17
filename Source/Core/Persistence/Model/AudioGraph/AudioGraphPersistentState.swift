//
//  AudioGraphPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the audio graph.
///
/// - SeeAlso:  `AudioGraph`
///
struct AudioGraphPersistentState: Codable {

    let outputDevice: AudioDevicePersistentState?
    
    let volume: Float?
    let muted: Bool?
    let pan: Float?
    
    let masterUnit: MasterUnitPersistentState?
    let eqUnit: EQUnitPersistentState?
    let pitchShiftUnit: PitchShiftUnitPersistentState?
    let timeStretchUnit: TimeStretchUnitPersistentState?
    let reverbUnit: ReverbUnitPersistentState?
    let delayUnit: DelayUnitPersistentState?
    let filterUnit: FilterUnitPersistentState?
    let replayGainUnit: ReplayGainUnitPersistentState?
    
    let audioUnits: [AudioUnitPersistentState]?
    let audioUnitPresets: AudioUnitPresetsPersistentState?
    
    let soundProfiles: [SoundProfilePersistentState]?
    
    init(outputDevice: AudioDevicePersistentState?,
         volume: Float?,
         muted: Bool?,
         pan: Float?,
         masterUnit: MasterUnitPersistentState?,
         eqUnit: EQUnitPersistentState?,
         pitchShiftUnit: PitchShiftUnitPersistentState?,
         timeStretchUnit: TimeStretchUnitPersistentState?,
         reverbUnit: ReverbUnitPersistentState?,
         delayUnit: DelayUnitPersistentState?,
         filterUnit: FilterUnitPersistentState?,
         replayGainUnit: ReplayGainUnitPersistentState?,
         audioUnits: [AudioUnitPersistentState]?,
         audioUnitPresets: AudioUnitPresetsPersistentState?,
         soundProfiles: [SoundProfilePersistentState]?) {
        
        self.outputDevice = outputDevice
        self.volume = volume
        self.muted = muted
        self.pan = pan
        
        self.masterUnit = masterUnit
        self.eqUnit = eqUnit
        self.pitchShiftUnit = pitchShiftUnit
        self.timeStretchUnit = timeStretchUnit
        self.reverbUnit = reverbUnit
        self.delayUnit = delayUnit
        self.filterUnit = filterUnit
        self.replayGainUnit = replayGainUnit
        self.audioUnits = audioUnits
        
        self.audioUnitPresets = audioUnitPresets
        self.soundProfiles = soundProfiles
    }
    
    init(legacyPersistentState: LegacyAudioGraphPersistentState?) {
        
        self.outputDevice = legacyPersistentState?.outputDevice
        
        self.volume = legacyPersistentState?.volume
        self.muted = legacyPersistentState?.muted
        self.pan = legacyPersistentState?.pan
        
        self.masterUnit = MasterUnitPersistentState(legacyPersistentState: legacyPersistentState?.masterUnit)
        self.eqUnit = EQUnitPersistentState(legacyPersistentState: legacyPersistentState?.eqUnit)
        self.pitchShiftUnit = PitchShiftUnitPersistentState(legacyPersistentState: legacyPersistentState?.pitchUnit)
        self.timeStretchUnit = TimeStretchUnitPersistentState(legacyPersistentState: legacyPersistentState?.timeUnit)
        self.reverbUnit = ReverbUnitPersistentState(legacyPersistentState: legacyPersistentState?.reverbUnit)
        self.delayUnit = DelayUnitPersistentState(legacyPersistentState: legacyPersistentState?.delayUnit)
        self.filterUnit = FilterUnitPersistentState(legacyPersistentState: legacyPersistentState?.filterUnit)
        self.replayGainUnit = nil
        
        self.audioUnits = legacyPersistentState?.audioUnits?.map {AudioUnitPersistentState(legacyPersistentState: $0)}
        self.audioUnitPresets = AudioUnitPresetsPersistentState(legacyPersistentState: legacyPersistentState?.audioUnitPresets)
        
        self.soundProfiles = legacyPersistentState?.soundProfiles?.map {SoundProfilePersistentState(legacyPersistentState: $0)}
    }
}
