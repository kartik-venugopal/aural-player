//
//  PitchShiftUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

///
/// Unit tests for **PitchShiftUnitPersistentState**.
///
class PitchShiftUnitPersistenceTests: AudioGraphTestCase {
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...(runLongRunningTests ? 1000 : 100) {
                
                let serializedState = PitchShiftUnitPersistentState(state: unitState,
                                                                    userPresets: randomPitchShiftPresets(unitState: .active),
                                                                    pitch: randomPitch(), overlap: randomOverlap())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
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
