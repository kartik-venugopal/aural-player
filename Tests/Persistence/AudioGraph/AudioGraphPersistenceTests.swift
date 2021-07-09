//
//  AudioGraphPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioGraphPersistenceTests: AudioGraphTestCase {
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            let outputDevice = AudioDevicePersistentState(name: randomDeviceName(),
                                                          uid: randomDeviceUID())
            
            let volume: Float? = randomVolume()
            let muted: Bool? = .random()
            let balance: Float? = randomBalance()
            
            let masterUnit: MasterUnitPersistentState? = MasterUnitPersistentState(state: randomUnitState(),
                                                                                   userPresets: randomMasterPresets())
            
            let eqType: EQType = randomEQType()
            let eqUnit: EQUnitPersistentState? = EQUnitPersistentState(state: randomUnitState(),
                                                                       userPresets: randomEQPresets(),
                                                                       type: eqType,
                                                                       globalGain: randomEQGlobalGain(),
                                                                       bands: eqType == .tenBand ? randomEQ10Bands() : randomEQ15Bands())
            
            let pitchUnit: PitchShiftUnitPersistentState? = PitchShiftUnitPersistentState(state: randomUnitState(),
                                                                                          userPresets: randomPitchShiftPresets(),
                                                                                          pitch: randomPitch(),
                                                                                          overlap: randomOverlap())
            
            let timeUnit: TimeStretchUnitPersistentState? = TimeStretchUnitPersistentState(state: randomUnitState(),
                                                                                           userPresets: randomTimeStretchPresets(),
                                                                                           rate: randomTimeStretchRate(),
                                                                                           shiftPitch: randomTimeStretchShiftPitch(),
                                                                                           overlap: randomOverlap())
            
            let reverbUnit: ReverbUnitPersistentState? = ReverbUnitPersistentState(state: randomUnitState(),
                                                                                   userPresets: randomReverbPresets(),
                                                                                   space: randomReverbSpace(),
                                                                                   amount: randomReverbAmount())
            
            let delayUnit: DelayUnitPersistentState? = DelayUnitPersistentState(state: randomUnitState(),
                                                                                userPresets: randomDelayPresets(),
                                                                                amount: randomDelayAmount(),
                                                                                time: randomDelayTime(),
                                                                                feedback: randomDelayFeedback(),
                                                                                lowPassCutoff: randomDelayLowPassCutoff())
            
            let filterUnit: FilterUnitPersistentState? = FilterUnitPersistentState(state: randomUnitState(),
                                                                                   userPresets: randomFilterPresets(),
                                                                                   bands: randomFilterBands())
            
            let numAU = Int.random(in: 0..<5)
            let audioUnits: [AudioUnitPersistentState]? = numAU == 0 ? [] : (0..<numAU).map {_ in
                
                AudioUnitPersistentState(state: randomUnitState(),
                                         userPresets: randomAUPresets(),
                                         componentType: randomAUOSType(),
                                         componentSubType: randomAUOSType(),
                                         params: randomAUParams())
            }
            
            let numProfiles = Int.random(in: 0..<20)
            let soundProfiles: [SoundProfilePersistentState]? = numProfiles == 0 ? [] : (0..<numProfiles).map {_ in
                
                SoundProfilePersistentState(file: randomAudioFile(), volume: randomVolume(), balance: randomBalance(),
                                            effects: randomMasterPresets(count: 1)[0])
            }
            
            let serializedState = AudioGraphPersistentState(outputDevice: outputDevice,
                                                            volume: volume,
                                                            muted: muted,
                                                            balance: balance,
                                                            masterUnit: masterUnit,
                                                            eqUnit: eqUnit,
                                                            pitchUnit: pitchUnit,
                                                            timeUnit: timeUnit,
                                                            reverbUnit: reverbUnit,
                                                            delayUnit: delayUnit,
                                                            filterUnit: filterUnit,
                                                            audioUnits: audioUnits,
                                                            soundProfiles: soundProfiles)
            
            doTestPersistence(serializedState: serializedState)
            
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension AudioGraphPersistentState: Equatable {
    
    static func == (lhs: AudioGraphPersistentState, rhs: AudioGraphPersistentState) -> Bool {
        
        lhs.outputDevice == rhs.outputDevice &&
        Float.approxEquals(lhs.volume, rhs.volume, accuracy: 0.001) &&
            lhs.muted == rhs.muted &&
            Float.approxEquals(lhs.balance, rhs.balance, accuracy: 0.001) &&
            lhs.masterUnit == rhs.masterUnit &&
            lhs.pitchUnit == rhs.pitchUnit &&
            lhs.timeUnit == rhs.timeUnit &&
            lhs.reverbUnit == rhs.reverbUnit &&
            lhs.delayUnit == rhs.delayUnit &&
            lhs.filterUnit == rhs.filterUnit &&
            lhs.audioUnits == rhs.audioUnits &&
            lhs.soundProfiles == rhs.soundProfiles
    }
}
