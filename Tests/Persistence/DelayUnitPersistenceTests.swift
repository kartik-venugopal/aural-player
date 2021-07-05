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
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomDelayPresets(unitState: .active),
                           amount: randomDelayAmount(), time: randomDelayTime(),
                           feedback: randomDelayFeedback(), lowPassCutoff: randomDelayLowPassCutoff())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState?, userPresets: [DelayPresetPersistentState],
                                   amount: Float, time: Double,
                                   feedback: Float, lowPassCutoff: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = DelayUnitPersistentState(state: unitState,
                                                       userPresets: userPresets,
                                                       amount: amount,
                                                       time: time,
                                                       feedback: feedback,
                                                       lowPassCutoff: lowPassCutoff)
        
        persistenceManager.save(serializedState)
        
        guard let persistentState = persistenceManager.load(type: DelayUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of DelayUnit state failed.")
            return
        }
        
        validateDelayUnitPersistentState(persistentState, unitState: unitState, userPresets: userPresets,
                                amount: amount, time: time, feedback: feedback, lowPassCutoff: lowPassCutoff)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension DelayPresetPersistentState: Equatable {
    
    static func == (lhs: DelayPresetPersistentState, rhs: DelayPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001) &&
            Double.approxEquals(lhs.time, rhs.time, accuracy: 0.001) &&
            Float.approxEquals(lhs.feedback, rhs.feedback, accuracy: 0.001) &&
            Float.approxEquals(lhs.lowPassCutoff, rhs.lowPassCutoff, accuracy: 0.001)
    }
}
