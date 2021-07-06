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
            
            for _ in 1...100 {
                
                let serializedState = TimeStretchUnitPersistentState(state: unitState,
                                                                     userPresets: randomTimeStretchPresets(unitState: .active),
                                                                     rate: randomTimeStretchRate(),
                                                                     shiftPitch: randomTimeStretchShiftPitch(),
                                                                     overlap: randomOverlap())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
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
