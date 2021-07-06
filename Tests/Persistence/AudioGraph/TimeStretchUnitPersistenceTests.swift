//
//  TimeStretchUnitPersistentState.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

///
/// Unit tests for **TimeStretchUnitPersistentState**.
///
class TimeStretchUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomTimeStretchPresets(unitState: .active),
                                  rate: randomTimeStretchRate(),
                                  shiftPitch: randomTimeStretchShiftPitch(), overlap: randomOverlap())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [TimeStretchPresetPersistentState],
                                   rate: Float, shiftPitch: Bool, overlap: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = TimeStretchUnitPersistentState(state: unitState,
                                                             userPresets: userPresets,
                                                             rate: rate,
                                                             shiftPitch: shiftPitch,
                                                             overlap: overlap)
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: TimeStretchUnitPersistentState.self) else {
            
            XCTFail("deserializedState is nil, deserialization of TimeStretchUnit state failed.")
            return
        }
        
        validateTimeStretchUnitPersistentState(deserializedState, unitState: unitState,
                                               userPresets: userPresets, rate: rate,
                                               shiftPitch: shiftPitch, overlap: overlap)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension TimeStretchUnitPersistentState: Equatable {
    
    static func == (lhs: TimeStretchUnitPersistentState, rhs: TimeStretchUnitPersistentState) -> Bool {
        
        lhs.userPresets == rhs.userPresets && lhs.state == rhs.state &&
            Float.approxEquals(lhs.rate, rhs.rate, accuracy: 0.001) &&
            lhs.shiftPitch == rhs.shiftPitch &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}

extension TimeStretchPresetPersistentState: Equatable {
    
    static func == (lhs: TimeStretchPresetPersistentState, rhs: TimeStretchPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            Float.approxEquals(lhs.rate, rhs.rate, accuracy: 0.001) &&
            lhs.shiftPitch == rhs.shiftPitch &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
