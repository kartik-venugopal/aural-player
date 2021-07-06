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
        
        let serializedState = PitchShiftUnitPersistentState(state: unitState,
                                                            userPresets: userPresets,
                                                            pitch: pitch,
                                                            overlap: overlap)
        
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

extension PitchShiftUnitPersistentState: Equatable {
    
    static func == (lhs: PitchShiftUnitPersistentState, rhs: PitchShiftUnitPersistentState) -> Bool {
        
        lhs.userPresets == rhs.userPresets && lhs.state == rhs.state &&
            Float.approxEquals(lhs.pitch, rhs.pitch, accuracy: 0.001) &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}

extension PitchShiftPresetPersistentState: Equatable {
    
    static func == (lhs: PitchShiftPresetPersistentState, rhs: PitchShiftPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            Float.approxEquals(lhs.pitch, rhs.pitch, accuracy: 0.001) &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
