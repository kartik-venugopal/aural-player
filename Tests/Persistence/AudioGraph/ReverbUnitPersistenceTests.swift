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
                
                for _ in 1...100 {
                    
                    let serializedState = ReverbUnitPersistentState(state: unitState,
                                                                    userPresets: randomReverbPresets(unitState: .active),
                                                                    space: space,
                                                                    amount: randomReverbAmount())
                    
                    doTestPersistence(serializedState: serializedState)
                }
            }
        }
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
