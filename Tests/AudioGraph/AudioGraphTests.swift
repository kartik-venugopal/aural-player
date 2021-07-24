//
//  AudioGraphTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioGraphTests: AudioGraphTestCase {
    
    func testInit() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
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
                
                SoundProfilePersistentState(file: randomAudioFile(), volume: randomVolume(), pan: randomPan(),
                                            effects: randomMasterPresets(count: 1)[0])
            }
            
            let persistentState = AudioGraphPersistentState(outputDevice: nil,
                                                            volume: randomVolume(),
                                                            muted: .random(),
                                                            pan: randomPan(),
                                                            masterUnit: master, eqUnit: eq, pitchUnit: pitchShift, timeUnit: timeStretch, reverbUnit: reverb, delayUnit: delay, filterUnit: filter, audioUnits: [], soundProfiles: soundProfiles)
            
            doTestInit(persistentState: persistentState)
        }
    }
    
    private func doTestInit(persistentState: AudioGraphPersistentState) {
        
        let audioGraph = AudioGraph(audioEngine: MockAudioEngine(), audioUnitsManager: AudioUnitsManager(), persistentState: persistentState)
        
        XCTAssertEqual(audioGraph.volume, persistentState.volume!, accuracy: 0.001)
        XCTAssertEqual(audioGraph.pan, persistentState.pan!, accuracy: 0.001)
        XCTAssertEqual(audioGraph.muted, persistentState.muted!)
        
        let masterUnit = audioGraph.masterUnit
        XCTAssertEqual(masterUnit.state, persistentState.masterUnit!.state!)
        let expectedMasterUnitPresets = persistentState.masterUnit!.userPresets!.map {MasterPreset(persistentState: $0)}
        XCTAssertEqual(Set(masterUnit.presets.userDefinedPresets), Set(expectedMasterUnitPresets))
        
        let eqUnit = audioGraph.eqUnit
        let eqState = persistentState.eqUnit!
        validate(eqUnit, persistentState: eqState)
        
        let pitchShiftUnit = audioGraph.pitchShiftUnit
        let pitchShiftState = persistentState.pitchUnit!
        validate(pitchShiftUnit, persistentState: pitchShiftState)
        
        let timeStretchUnit = audioGraph.timeStretchUnit
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
    }
    
    func testVolume() {
        
        let audioGraph = AudioGraph(audioEngine: MockAudioEngine(), audioUnitsManager: AudioUnitsManager(), persistentState: nil)
        
        for _ in 1...1000 {
            
            let volume = randomVolume()
            audioGraph.volume = volume
            
            XCTAssertEqual(audioGraph.volume, volume, accuracy: 0.001)
            XCTAssertEqual(audioGraph.playerNode.volume, volume, accuracy: 0.001)
        }
    }
    
    func testPan() {
        
        let audioGraph = AudioGraph(audioEngine: MockAudioEngine(), audioUnitsManager: AudioUnitsManager(), persistentState: nil)
        
        for _ in 1...1000 {
            
            let pan = randomPan()
            audioGraph.pan = pan
            
            XCTAssertEqual(audioGraph.pan, pan, accuracy: 0.001)
            XCTAssertEqual(audioGraph.playerNode.pan, pan, accuracy: 0.001)
        }
    }
    
    func testMuted() {
        
        let audioGraph = AudioGraph(audioEngine: MockAudioEngine(), audioUnitsManager: AudioUnitsManager(), persistentState: nil)
        
        for _ in 1...1000 {
            
            let muted = Bool.random()
            audioGraph.muted = muted
            
            XCTAssertEqual(audioGraph.muted, muted)
            XCTAssertEqual(audioGraph.auxMixer.muted, muted)
            XCTAssertEqual(audioGraph.auxMixer.volume, muted ? 0 : 1, accuracy: 0.001)
        }
    }
    
    func testAddAndRemoveAudioUnits() {
        
        let auManager = AudioUnitsManager()
        let audioEngine = MockAudioEngine()
        let audioUnits = auManager.audioUnits
        
        for _ in 1...100 {
            
            let audioGraph = AudioGraph(audioEngine: audioEngine, audioUnitsManager: auManager, persistentState: nil)
            let numAudioUnits = Int.random(in: 1...10)
            
            for index in 0..<numAudioUnits {
                
                let audioUnit = audioUnits.randomElement()
                
                guard let addResult = audioGraph.addAudioUnit(ofType: audioUnit.componentType, andSubType: audioUnit.componentSubType) else {
                    
                    XCTFail("Audio Graph failed to add an audio unit.")
                    continue
                }
                
                let addedAudioUnit = addResult.audioUnit
                
                XCTAssertEqual(addedAudioUnit.componentType, audioUnit.componentType)
                XCTAssertEqual(addedAudioUnit.componentSubType, audioUnit.componentSubType)
                XCTAssertEqual(addResult.index, index)
                
                XCTAssertTrue(audioGraph.audioUnits[index] === addResult.audioUnit)
                XCTAssertEqual(audioGraph.audioUnits.count, index + 1)
            }
            
            while audioGraph.audioUnits.count > 0 {
                
                let countBeforeRemove = audioGraph.audioUnits.count
                
                let numUnitsToRemove = Int.random(in: 1...countBeforeRemove)
                let randomIndices = Set((1...numUnitsToRemove).map {_ in Int.random(in: 0..<countBeforeRemove)})
                
                let removedAudioUnits = randomIndices.map {audioGraph.audioUnits[$0]}
                
                audioGraph.removeAudioUnits(at: IndexSet(randomIndices))
                XCTAssertEqual(audioGraph.audioUnits.count, countBeforeRemove - randomIndices.count)
                
                for audioUnit in removedAudioUnits {
                    XCTAssertFalse(audioGraph.audioUnits.contains(where: {$0 === audioUnit}))
                }
            }
        }
    }
    
    // TODO
    func testSettingsAsMasterPreset() {
        
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension SoundProfile: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.file)
    }
    
    static func == (lhs: SoundProfile, rhs: SoundProfile) -> Bool {
        
        lhs.file == rhs.file && Float.approxEquals(lhs.volume, rhs.volume, accuracy: 0.001) &&
            Float.approxEquals(lhs.pan, rhs.pan, accuracy: 0.001)
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
