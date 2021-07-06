//
//  DelayUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class DelayUnitPersistenceTests: AudioGraphPersistenceTestCase {

    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...100 {
                
                let serializedState = DelayUnitPersistentState(state: unitState,
                                                               userPresets: randomDelayPresets(unitState: .active),
                                                               amount: randomDelayAmount(),
                                                               time: randomDelayTime(),
                                                               feedback: randomDelayFeedback(),
                                                               lowPassCutoff: randomDelayLowPassCutoff())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension DelayUnitPersistentState: Equatable {
    
    static func == (lhs: DelayUnitPersistentState, rhs: DelayUnitPersistentState) -> Bool {
        
        lhs.userPresets == rhs.userPresets && lhs.state == rhs.state &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001) &&
            Double.approxEquals(lhs.time, rhs.time, accuracy: 0.001) &&
            Float.approxEquals(lhs.feedback, rhs.feedback, accuracy: 0.001) &&
            Float.approxEquals(lhs.lowPassCutoff, rhs.lowPassCutoff, accuracy: 0.001)
    }
}

extension DelayPresetPersistentState: Equatable {
    
    static func == (lhs: DelayPresetPersistentState, rhs: DelayPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001) &&
            Double.approxEquals(lhs.time, rhs.time, accuracy: 0.001) &&
            Float.approxEquals(lhs.feedback, rhs.feedback, accuracy: 0.001) &&
            Float.approxEquals(lhs.lowPassCutoff, rhs.lowPassCutoff, accuracy: 0.001)
    }
}
