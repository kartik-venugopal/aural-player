//
//  DelayUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class DelayUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = DelayUnitPersistentState(state: unitState,
                                                               userPresets: randomDelayPresets(unitState: .active),
                                                               amount: randomDelayAmount(),
                                                               time: randomDelayTime(),
                                                               feedback: randomDelayFeedback(),
                                                               lowPassCutoff: randomDelayLowPassCutoff())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    private func doTestInit(persistentState: DelayUnitPersistentState) {
        
        let delayUnit = DelayUnit(persistentState: persistentState)
        validate(delayUnit, persistentState: persistentState)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension DelayPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: DelayPreset, rhs: DelayPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001) &&
            Double.approxEquals(lhs.time, rhs.time, accuracy: 0.001) &&
            Float.approxEquals(lhs.feedback, rhs.feedback, accuracy: 0.001) &&
            Float.approxEquals(lhs.lowPassCutoff, rhs.lowPassCutoff, accuracy: 0.001)
    }
}
