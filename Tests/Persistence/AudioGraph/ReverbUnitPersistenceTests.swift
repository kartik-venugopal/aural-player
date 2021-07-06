//
//  ReverbUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class ReverbUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for space in ReverbSpaces.allCases {
                
                for _ in 0..<100 {
                    
                    doTestPersistence(unitState: unitState, userPresets: randomReverbPresets(unitState: .active),
                               space: space, amount: randomReverbAmount())
                }
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [ReverbPresetPersistentState],
                                   space: ReverbSpaces, amount: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = ReverbUnitPersistentState(state: unitState,
                                                        userPresets: userPresets,
                                                        space: space,
                                                        amount: amount)
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: ReverbUnitPersistentState.self) else {
            
            XCTFail("deserializedState is nil, deserialization of ReverbUnit state failed.")
            return
        }
        
        validateReverbUnitPersistentState(deserializedState, unitState: unitState,
                                userPresets: userPresets,
                                space: space, amount: amount)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ReverbUnitPersistentState: Equatable {
    
    static func == (lhs: ReverbUnitPersistentState, rhs: ReverbUnitPersistentState) -> Bool {
        
        lhs.userPresets == rhs.userPresets && lhs.state == rhs.state && lhs.space == rhs.space &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001)
    }
}

extension ReverbPresetPersistentState: Equatable {
    
    static func == (lhs: ReverbPresetPersistentState, rhs: ReverbPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.space == rhs.space &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001)
    }
}
