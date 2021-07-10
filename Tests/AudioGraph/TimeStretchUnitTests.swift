//
//  TimeStretchUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class TimeStretchUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = TimeStretchUnitPersistentState(state: unitState,
                                                                     userPresets: randomTimeStretchPresets(unitState: .active),
                                                                     rate: randomTimeStretchRate(),
                                                                     shiftPitch: randomTimeStretchShiftPitch(),
                                                                     overlap: randomOverlap())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    // TODO: Test with invalid / missing values in persistent state.
    
    private func doTestInit(persistentState: TimeStretchUnitPersistentState) {
        
        let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
        validate(timeStretchUnit, persistentState: persistentState)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension TimeStretchPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: TimeStretchPreset, rhs: TimeStretchPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            Float.approxEquals(lhs.rate, rhs.rate, accuracy: 0.001) &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
