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
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.eqState, userPresets: [],
                   type: AudioGraphDefaults.eqType,
                   globalGain: AudioGraphDefaults.eqGlobalGain,
                   bands: AudioGraphDefaults.eqBands)
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, type: nil, globalGain: nil, bands: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        doTestInit(unitState: .active, userPresets: nil, type: nil,
                   globalGain: nil, bands: nil)
        
        doTestInit(unitState: .bypassed, userPresets: nil, type: nil,
                   globalGain: nil, bands: nil)
        
        doTestInit(unitState: .suppressed, userPresets: nil, type: nil,
                   globalGain: nil, bands: nil)
        
        doTestInit(unitState: .active, userPresets: nil, type: nil,
                   globalGain: nil, bands: randomEQ10Bands())
        
        doTestInit(unitState: .active, userPresets: randomNillableEQPresets(unitState: .active), type: nil,
                   globalGain: nil, bands: randomEQ15Bands())
        
        doTestInit(unitState: .bypassed, userPresets: randomNillableEQPresets(unitState: .active), type: .tenBand,
                   globalGain: randomEQGlobalGain(), bands: nil)
        
        doTestInit(unitState: .suppressed, userPresets: randomNillableEQPresets(unitState: .active), type: .fifteenBand,
                   globalGain: randomEQGlobalGain(), bands: nil)
        
        for _ in 0..<100 {
            
            let eqType = randomNillableEQType()
            
            doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillableEQPresets(unitState: .active),
                       type: eqType, globalGain: randomNillableEQGlobalGain(),
                       bands: eqType == EQType.fifteenBand ?
                        randomNillableEQ15Bands() : randomNillableEQ10Bands())
        }
    }
    
    func testInit_10BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: state, userPresets: randomEQPresets(unitState: .active),
                           type: .tenBand, globalGain: randomEQGlobalGain(),
                           bands: randomEQ10Bands())
                
            }
        }
    }
    
    func testInit_15BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: state, userPresets: randomEQPresets(unitState: .active),
                           type: .fifteenBand, globalGain: randomEQGlobalGain(),
                           bands: randomEQ15Bands())
            }
        }
    }
    
    // TODO:
    //    func testEQBandsAndTypeMismatch() {
    //
    //    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [EQPresetPersistentState]?,
                            type: EQType?, globalGain: Float?, bands: [Float]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["type"] = type?.rawValue
        dict["globalGain"] = globalGain
        dict["bands"] = bands
        
        guard let persistentState = EQUnitPersistentState(dict) else {
            
            XCTFail("persistentState is nil, init of EQUnit state failed.")
            return
        }
        
        validateEQUnitPersistentState(persistentState, unitState: unitState,
                                      userPresets: userPresets, type: type, globalGain: globalGain, bands: bands)
    }
    
    // MARK: Persistence tests --------------------------------------------
    
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
        
        let serializedState = EQUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.type = type
        serializedState.bands = bands
        serializedState.globalGain = globalGain
        
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

extension EQPresetPersistentState: Equatable {
    
    static func == (lhs: EQPresetPersistentState, rhs: EQPresetPersistentState) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            lhs.bands.approxEquals(rhs.bands, accuracy: 0.001) &&
            Float.approxEquals(lhs.globalGain, rhs.globalGain, accuracy: 0.001)
    }
}
