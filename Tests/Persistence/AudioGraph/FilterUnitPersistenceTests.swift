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
            
            for _ in 1...100 {
                
                let serializedState = FilterUnitPersistentState(state: state,
                                                                userPresets: randomFilterPresets(unitState: .active),
                                                                bands: randomFilterBands())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FilterUnitPersistentState: Equatable {
    
    static func == (lhs: FilterUnitPersistentState, rhs: FilterUnitPersistentState) -> Bool {
        lhs.userPresets == rhs.userPresets && lhs.state == rhs.state && lhs.bands == rhs.bands
    }
}

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
