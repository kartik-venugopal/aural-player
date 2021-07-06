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
            
            for _ in 0..<100 {
                doTestPersistence(unitState: state, userPresets: randomMasterPresets())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [MasterPresetPersistentState]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = MasterUnitPersistentState(state: unitState, userPresets: userPresets)
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: MasterUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, init of EQUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState,
                                userPresets: userPresets)
    }
    
    // MARK: Helper functions ---------------------------------------
    
    private func randomNillablePresets() -> [MasterPresetPersistentState]? {
        randomNillableValue {self.randomMasterPresets()}
    }
    
    private func validatePersistentState(persistentState: MasterUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [MasterPresetPersistentState]?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of EQUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, userPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
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
