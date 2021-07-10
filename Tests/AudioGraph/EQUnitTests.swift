//
//  EQUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class EQUnitTests: AudioGraphTestCase {
    
    func testInit_10BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = EQUnitPersistentState(state: state,
                                                            userPresets: randomEQPresets(unitState: .active),
                                                            type: .tenBand, globalGain: randomEQGlobalGain(),
                                                            bands: randomEQ10Bands())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    func testInit_15BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = EQUnitPersistentState(state: state,
                                                            userPresets: randomEQPresets(unitState: .active),
                                                            type: .fifteenBand, globalGain: randomEQGlobalGain(),
                                                            bands: randomEQ15Bands())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    // TODO: Test with invalid / missing values in persistent state.
    
    private func doTestInit(persistentState: EQUnitPersistentState) {
        
        let eqUnit = EQUnit(persistentState: persistentState)
        validate(eqUnit, persistentState: persistentState)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension EQPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: EQPreset, rhs: EQPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            [Float].approxEquals(lhs.bands, rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}
