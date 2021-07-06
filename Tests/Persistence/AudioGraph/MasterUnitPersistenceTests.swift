//
//  MasterUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class MasterUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...100 {
                
                let serializedState = MasterUnitPersistentState(state: state, userPresets: randomMasterPresets())
                doTestPersistence(serializedState: serializedState)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension MasterUnitPersistentState: Equatable {
    
    static func == (lhs: MasterUnitPersistentState, rhs: MasterUnitPersistentState) -> Bool {
        lhs.state == rhs.state && lhs.userPresets == rhs.userPresets
    }
}

extension MasterPresetPersistentState: Equatable {
    
    static func == (lhs: MasterPresetPersistentState, rhs: MasterPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            lhs.eq == rhs.eq && lhs.pitch == rhs.pitch &&
            lhs.time == rhs.time && lhs.reverb == rhs.reverb &&
            lhs.filter == rhs.filter
    }
}
