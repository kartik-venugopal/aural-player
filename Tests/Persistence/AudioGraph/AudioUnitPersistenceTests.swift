//
//  AudioUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioUnitPersistenceTests: AudioGraphTestCase {
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...100 {
                
                let serializedState = AudioUnitPersistentState(state: unitState, userPresets: randomAUPresets(),
                                                               componentType: randomAUOSType(), componentSubType: randomAUOSType(),
                                                               params: randomAUParams())
                
                doTestPersistence(serializedState: serializedState)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension AudioUnitPersistentState: Equatable {
    
    static func == (lhs: AudioUnitPersistentState, rhs: AudioUnitPersistentState) -> Bool {
        
        lhs.userPresets == rhs.userPresets && lhs.state == rhs.state &&
            lhs.componentType == rhs.componentType &&
            lhs.componentSubType == rhs.componentSubType &&
            lhs.params == rhs.params
    }
}

extension AudioUnitPresetPersistentState: Equatable {
    
    static func == (lhs: AudioUnitPresetPersistentState, rhs: AudioUnitPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.componentType == rhs.componentType
            && lhs.componentSubType == rhs.componentSubType && lhs.number == rhs.number
    }
}

extension AudioUnitParameterPersistentState: Equatable {
    
    static func == (lhs: AudioUnitParameterPersistentState, rhs: AudioUnitParameterPersistentState) -> Bool {
        lhs.address == rhs.address && Float.approxEquals(lhs.value, rhs.value, accuracy: 0.000001)
    }
}
