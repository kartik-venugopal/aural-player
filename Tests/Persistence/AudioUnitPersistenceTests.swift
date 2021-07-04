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

class AudioUnitPersistenceTests: PersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_noValuesAvailable() {
        
        doTestInit(unitState: nil, userPresets: nil,
                   componentType: nil, componentSubType: nil,
                   params: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        for unitState in EffectsUnitState.allCases {
            
            doTestInit(unitState: unitState, userPresets: randomNillablePresets(),
                       componentType: randomNillableOSType(), componentSubType: randomNillableOSType(),
                       params: randomNillableParams())
        }
        
        doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillablePresets(),
                   componentType: randomNillableOSType(), componentSubType: randomNillableOSType(),
                   params: randomNillableParams())
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            doTestInit(unitState: unitState, userPresets: randomPresets(),
                       componentType: randomOSType(), componentSubType: randomOSType(),
                       params: randomParams())
        }
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomUnitState(), userPresets: randomPresets(),
                       componentType: randomOSType(), componentSubType: randomOSType(),
                       params: randomParams())
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [AudioUnitPresetPersistentState]?,
                            componentType: OSType?, componentSubType: OSType?,
                            params: [AudioUnitParameterPersistentState]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["componentType"] = componentType
        dict["componentSubType"] = componentSubType
        dict["params"] = params == nil ? nil : NSArray(array: params!.map {JSONMapper.map($0)})
        
        // componentType and componentSubType are both required for AudioUnitPersistentState.
        if componentType == nil || componentSubType == nil {
            
            XCTAssertNil(AudioUnitPersistentState(dict))
            return
        }
        
        guard let persistentState = AudioUnitPersistentState(dict) else {
            
            XCTFail("persistentState is nil, init of AudioUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets, componentType: componentType,
                                componentSubType: componentSubType, params: params)
    }
    
    // MARK: Persistence tests -------------------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            doTestPersistence(unitState: unitState, userPresets: randomPresets(),
                              componentType: randomOSType(), componentSubType: randomOSType(),
                              params: randomParams())
        }
        
        for _ in 0..<100 {
            
            doTestPersistence(unitState: randomUnitState(), userPresets: randomPresets(),
                              componentType: randomOSType(), componentSubType: randomOSType(),
                              params: randomParams())
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [AudioUnitPresetPersistentState],
                                   componentType: OSType, componentSubType: OSType,
                                   params: [AudioUnitParameterPersistentState]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = AudioUnitPersistentState(componentType: componentType, componentSubType: componentSubType,
                                             params: params, state: unitState, userPresets: userPresets)
        
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
    
    private func randomNillableParams() -> [AudioUnitParameterPersistentState]? {
        randomNillableValue {self.randomParams()}
    }
    
    private func randomParams() -> [AudioUnitParameterPersistentState] {
        
        let numParams = Int.random(in: 1...100)
        
        return (1...numParams).map {_ in
            AudioUnitParameterPersistentState(address: randomParamAddress(), value: randomParamValue())
        }
    }
    
    private func randomParamAddress() -> UInt64 {
        UInt64.random(in: 1...UInt64.max)
    }
    
    private func randomParamValue() -> Float {
        Float.random(in: -10000000...Float.greatestFiniteMagnitude)
    }

    private func randomNillableOSType() -> OSType? {
        randomNillableValue {self.randomOSType()}
    }
    
    private func randomOSType() -> OSType {
        OSType.random(in: OSType.min...OSType.max)
    }
    
    private func randomPresetNumber() -> Int {
        Int.random(in: 0...Int.max)
    }
    
    private func randomNillablePresets() -> [AudioUnitPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func randomPresets() -> [AudioUnitPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in

            AudioUnitPresetPersistentState(preset: AudioUnitPreset("preset-\(index)", .active,
                                                                 false, componentType: randomOSType(), componentSubType: randomOSType(), number: randomPresetNumber()))
        }
    }
    
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

extension AudioUnitPresetPersistentState: Equatable {
    
    static func == (lhs: AudioUnitPresetPersistentState, rhs: AudioUnitPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.componentType == rhs.componentType
            && lhs.componentSubType == rhs.componentSubType && lhs.number == rhs.number
    }
}

extension AudioUnitParameterPersistentState: Equatable {
    
    static func == (lhs: AudioUnitParameterPersistentState, rhs: AudioUnitParameterPersistentState) -> Bool {
        lhs.address == rhs.address && lhs.value.approxEquals(rhs.value, accuracy: 0.000001)
    }
}
