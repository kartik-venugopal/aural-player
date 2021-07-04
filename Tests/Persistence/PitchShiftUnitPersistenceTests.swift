//
//  PitchShiftUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

///
/// Unit tests for **PitchShiftUnitPersistentState**.
///
class PitchShiftUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.pitchState, userPresets: [],
                   pitch: AudioGraphDefaults.pitch,
                   overlap: AudioGraphDefaults.pitchOverlap)
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, pitch: nil, overlap: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        doTestInit(unitState: .active, userPresets: [], pitch: nil, overlap: randomOverlap())
        doTestInit(unitState: .bypassed, userPresets: nil, pitch: randomPitch(), overlap: randomOverlap())
        doTestInit(unitState: .suppressed, userPresets: nil, pitch: nil, overlap: randomOverlap())
        
        doTestInit(unitState: nil, userPresets: [], pitch: nil, overlap: randomOverlap())
        doTestInit(unitState: nil, userPresets: nil, pitch: randomPitch(), overlap: nil)
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(),
                       userPresets: randomNillablePitchShiftPresets(unitState: .active),
                       pitch: randomNillablePitch(),
                       overlap: randomNillableOverlap())
        }
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: unitState, userPresets: randomPitchShiftPresets(unitState: .active),
                           pitch: randomPitch(), overlap: randomOverlap())
            }
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [PitchShiftPresetPersistentState]?,
                            pitch: Float?, overlap: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["pitch"] = pitch
        dict["overlap"] = overlap
        
        let optionalPersistentState = PitchShiftUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of PitchShiftUnit state failed.")
            return
        }
        
        validatePitchShiftUnitPersistentState(persistentState, unitState: unitState,
                                              userPresets: userPresets, pitch: pitch, overlap: overlap)
    }
    
    // MARK: Persistence tests ---------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomPitchShiftPresets(unitState: .active),
                                  pitch: randomPitch(), overlap: randomOverlap())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [PitchShiftPresetPersistentState],
                                   pitch: Float, overlap: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = PitchShiftUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.pitch = pitch
        serializedState.overlap = overlap
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: PitchShiftUnitPersistentState.self) else {
            
            XCTFail("deserializedState is nil, deserialization of PitchShiftUnit state failed.")
            return
        }
        
        validatePitchShiftUnitPersistentState(deserializedState, unitState: unitState,
                                              userPresets: userPresets, pitch: pitch, overlap: overlap)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PitchShiftPresetPersistentState: Equatable {
    
    static func == (lhs: PitchShiftPresetPersistentState, rhs: PitchShiftPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            lhs.pitch.approxEquals(rhs.pitch, accuracy: 0.001) &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
