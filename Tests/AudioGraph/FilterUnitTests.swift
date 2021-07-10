//
//  FilterUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FilterUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = FilterUnitPersistentState(state: unitState,
                                                                userPresets: randomFilterPresets(unitState: .active),
                                                                bands: randomFilterBands())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    private func doTestInit(persistentState: FilterUnitPersistentState) {
        
        let filterUnit = FilterUnit(persistentState: persistentState)
        validate(filterUnit, persistentState: persistentState)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FilterPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: FilterPreset, rhs: FilterPreset) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.bands == rhs.bands
    }
}

extension FilterBand: Equatable {
    
    static func == (lhs: FilterBand, rhs: FilterBand) -> Bool {
        
        lhs.type == rhs.type &&
            Float.approxEquals(lhs.minFreq, rhs.minFreq, accuracy: 0.001) &&
            Float.approxEquals(lhs.maxFreq, rhs.maxFreq, accuracy: 0.001)
    }
}
