//
//  AudioGraphUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioGraphUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for _ in 1...100 {
            
            let master = MasterUnitPersistentState(state: Bool.random() ? .active : .bypassed, userPresets: randomMasterPresets())
            
            let eq = EQUnitPersistentState(state: randomUnitState(),
                                           userPresets: randomEQPresets(unitState: .active),
                                           type: .tenBand, globalGain: randomEQGlobalGain(),
                                           bands: randomEQ10Bands())
            
            let pitchShift = PitchShiftUnitPersistentState(state: randomUnitState(),
                                                           userPresets: randomPitchShiftPresets(unitState: .active),
                                                           pitch: randomPitch(), overlap: randomOverlap())
            
            let timeStretch = TimeStretchUnitPersistentState(state: randomUnitState(),
                                                                 userPresets: randomTimeStretchPresets(unitState: .active),
                                                                 rate: randomTimeStretchRate(),
                                                                 shiftPitch: randomTimeStretchShiftPitch(),
                                                                 overlap: randomOverlap())
            
            let reverb = ReverbUnitPersistentState(state: randomUnitState(),
                                                   userPresets: randomReverbPresets(unitState: .active),
                                                   space: randomReverbSpace(),
                                                   amount: randomReverbAmount())
            
            let delay = DelayUnitPersistentState(state: randomUnitState(),
                                                 userPresets: randomDelayPresets(unitState: .active),
                                                 amount: randomDelayAmount(),
                                                 time: randomDelayTime(),
                                                 feedback: randomDelayFeedback(),
                                                 lowPassCutoff: randomDelayLowPassCutoff())
            
            let filter = FilterUnitPersistentState(state: randomUnitState(),
                                                   userPresets: randomFilterPresets(unitState: .active),
                                                   bands: randomFilterBands())
            
            let numProfiles = Int.random(in: 0..<20)
            let soundProfiles: [SoundProfilePersistentState]? = numProfiles == 0 ? [] : (0..<numProfiles).map {_ in
                
                SoundProfilePersistentState(file: randomAudioFile(), volume: randomVolume(), balance: randomBalance(),
                                            effects: randomMasterPresets(count: 1)[0])
            }
            
            let persistentState = AudioGraphPersistentState(outputDevice: nil,
                                                            volume: randomVolume(),
                                                            muted: .random(),
                                                            balance: randomBalance(),
                                                            masterUnit: master, eqUnit: eq, pitchUnit: pitchShift, timeUnit: timeStretch, reverbUnit: reverb, delayUnit: delay, filterUnit: filter, audioUnits: [], soundProfiles: soundProfiles)
            
            doTestInit(persistentState: persistentState)
        }
    }
    
    private func doTestInit(persistentState: AudioGraphPersistentState) {
        
        let audioGraph = AudioGraph(AudioUnitsManager(), persistentState)
        
        XCTAssertEqual(audioGraph.volume, persistentState.volume!, accuracy: 0.001)
        XCTAssertEqual(audioGraph.balance, persistentState.balance!, accuracy: 0.001)
        XCTAssertEqual(audioGraph.muted, persistentState.muted!)
        
        let masterUnit = audioGraph.masterUnit
        XCTAssertEqual(masterUnit.state, persistentState.masterUnit!.state!)
        let expectedMasterUnitPresets = persistentState.masterUnit!.userPresets!.map {MasterPreset(persistentState: $0)}
        XCTAssertEqual(Set(masterUnit.presets.userDefinedPresets), Set(expectedMasterUnitPresets))
        
        let eqUnit = audioGraph.eqUnit
        let eqState = persistentState.eqUnit!
        validate(eqUnit, persistentState: eqState)
        
        let pitchShiftUnit = audioGraph.pitchUnit
        let pitchShiftState = persistentState.pitchUnit!
        validate(pitchShiftUnit, persistentState: pitchShiftState)
        
        let timeStretchUnit = audioGraph.timeUnit
        let timeStretchState = persistentState.timeUnit!
        validate(timeStretchUnit, persistentState: timeStretchState)
        
        let reverbUnit = audioGraph.reverbUnit
        let reverbState = persistentState.reverbUnit!
        validate(reverbUnit, persistentState: reverbState)
        
        let delayUnit = audioGraph.delayUnit
        let delayState = persistentState.delayUnit!
        validate(delayUnit, persistentState: delayState)
        
        let filterUnit = audioGraph.filterUnit
        let filterState = persistentState.filterUnit!
        validate(filterUnit, persistentState: filterState)
        
        let expectedSoundProfiles = SoundProfiles(persistentState: persistentState.soundProfiles)
        XCTAssertEqual(Set(audioGraph.soundProfiles.all()), Set(expectedSoundProfiles.all()))
        
        audioGraph.tearDown()
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension SoundProfile: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.file)
    }
    
    static func == (lhs: SoundProfile, rhs: SoundProfile) -> Bool {
        
        lhs.file == rhs.file && Float.approxEquals(lhs.volume, rhs.volume, accuracy: 0.001) &&
            Float.approxEquals(lhs.balance, rhs.balance, accuracy: 0.001)
            && lhs.effects == rhs.effects
    }
}

extension MasterPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: MasterPreset, rhs: MasterPreset) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            lhs.eq == rhs.eq && lhs.pitch == rhs.pitch &&
            lhs.time == rhs.time && lhs.reverb == rhs.reverb &&
            lhs.filter == rhs.filter
    }
}
