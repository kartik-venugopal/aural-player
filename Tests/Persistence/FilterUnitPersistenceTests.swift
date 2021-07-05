//
//  FilterUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FilterUnitPersistenceTests: AudioGraphPersistenceTestCase {

    func testPersistence() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomFilterPresets(unitState: .active),
                                  bands: randomFilterBands())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [FilterPresetPersistentState],
                                   bands: [FilterBandPersistentState]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = FilterUnitPersistentState(state: unitState,
                                                        userPresets: userPresets,
                                                        bands: bands)
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: FilterUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of FilterUnit state failed.")
            return
        }
        
        validateFilterUnitPersistentState(persistentState: deserializedState, unitState: unitState,
                                          userPresets: userPresets, bands: bands)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FilterPresetPersistentState: Equatable {
    
    static func == (lhs: FilterPresetPersistentState, rhs: FilterPresetPersistentState) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.bands == rhs.bands
    }
}

extension FilterBandPersistentState: Equatable {
    
    static func == (lhs: FilterBandPersistentState, rhs: FilterBandPersistentState) -> Bool {
        
        lhs.type == rhs.type &&
            Float.approxEquals(lhs.minFreq, rhs.minFreq, accuracy: 0.001) &&
            Float.approxEquals(lhs.maxFreq, rhs.maxFreq, accuracy: 0.001)
    }
}
