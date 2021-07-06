//
//  EQUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

///
/// Unit tests for **EQUnitPersistentState**.
///
class EQUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence_10BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomEQPresets(unitState: .active),
                                  type: .tenBand, globalGain: randomEQGlobalGain(),
                                  bands: randomEQ10Bands())
                
            }
        }
    }
    
    func testPersistence_15BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomEQPresets(unitState: .active),
                                  type: .fifteenBand, globalGain: randomEQGlobalGain(),
                                  bands: randomEQ15Bands())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [EQPresetPersistentState],
                                   type: EQType, globalGain: Float, bands: [Float]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = EQUnitPersistentState(state: unitState,
            userPresets: userPresets,
            type: type,
            globalGain: globalGain,
            bands: bands)

        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: EQUnitPersistentState.self) else {
            
            XCTFail("deserializedState is nil, deserialization of EQUnit state failed.")
            return
        }
        
        validateEQUnitPersistentState(deserializedState, unitState: unitState,
                                      userPresets: userPresets, type: type, globalGain: globalGain, bands: bands)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension EQUnitPersistentState: Equatable {
    
    static func == (lhs: EQUnitPersistentState, rhs: EQUnitPersistentState) -> Bool {
        
        lhs.state == rhs.state && lhs.userPresets == rhs.userPresets &&
            lhs.type == rhs.type &&
            [Float].approxEquals(lhs.bands, rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}

extension EQPresetPersistentState: Equatable {
    
    static func == (lhs: EQPresetPersistentState, rhs: EQPresetPersistentState) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            [Float].approxEquals(lhs.bands, rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}
