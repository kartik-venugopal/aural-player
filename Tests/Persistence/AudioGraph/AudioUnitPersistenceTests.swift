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

class AudioUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            doTestPersistence(unitState: unitState, userPresets: randomAUPresets(),
                              componentType: randomAUOSType(), componentSubType: randomAUOSType(),
                              params: randomAUParams())
        }
        
        for _ in 0..<100 {
            
            doTestPersistence(unitState: randomUnitState(), userPresets: randomAUPresets(),
                              componentType: randomAUOSType(), componentSubType: randomAUOSType(),
                              params: randomAUParams())
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [AudioUnitPresetPersistentState],
                                   componentType: OSType, componentSubType: OSType,
                                   params: [AudioUnitParameterPersistentState]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = AudioUnitPersistentState(state: unitState, userPresets: userPresets,
                                                       componentType: componentType,
                                                       componentSubType: componentSubType,
                                                       params: params)
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: AudioUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, init of AudioUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState,
                                userPresets: userPresets, componentType: componentType,
                                componentSubType: componentSubType, params: params)
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func validatePersistentState(persistentState: AudioUnitPersistentState, unitState: EffectsUnitState?,
                                         userPresets: [AudioUnitPresetPersistentState]?,
                                         componentType: OSType?, componentSubType: OSType?,
                                         params: [AudioUnitParameterPersistentState]?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of AudioUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.componentType, componentType)
        XCTAssertEqual(persistentState.componentSubType, componentSubType)
        XCTAssertEqual(persistentState.params, params)
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
