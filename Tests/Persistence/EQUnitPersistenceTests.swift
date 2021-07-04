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
class EQUnitPersistenceTests: PersistenceTestCase {
    
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
                   globalGain: nil, bands: tenRandomBands())
        
        doTestInit(unitState: .active, userPresets: nil, type: nil,
                   globalGain: nil, bands: fifteenRandomBands())
        
        doTestInit(unitState: .bypassed, userPresets: [], type: .tenBand,
                   globalGain: randomGlobalGain(), bands: nil)
        
        doTestInit(unitState: .suppressed, userPresets: [], type: .fifteenBand,
                   globalGain: randomGlobalGain(), bands: nil)
        
        for _ in 0..<100 {
            
            let eqType = randomNillableEQType()
            
            doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillablePresets(),
                       type: eqType, globalGain: randomNillableGlobalGain(),
                       bands: eqType == EQType.fifteenBand ?
                        randomNillableFifteenBands() : randomNillableTenBands())
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
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets, type: type, globalGain: globalGain, bands: bands)
    }
    
    // MARK: Persistence tests --------------------------------------------
    
    func testPersistence_10BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomPresets(),
                                  type: .tenBand, globalGain: randomGlobalGain(),
                                  bands: tenRandomBands())
                
            }
        }
    }
    
    func testPersistence_15BandEQ() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomPresets(),
                                  type: .fifteenBand, globalGain: randomGlobalGain(),
                                  bands: fifteenRandomBands())
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
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState,
                                userPresets: userPresets, type: type, globalGain: globalGain, bands: bands)
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func randomNillablePresets() -> [EQPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func randomPresets() -> [EQPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            EQPresetPersistentState(preset: EQPreset("preset-\(index)", .active,
                                                     fifteenRandomBands(), randomGlobalGain(),
                                                     false))
        }
    }
    
    private func randomEQType() -> EQType {EQType.randomCase()}
    
    private func randomNillableEQType() -> EQType? {
        randomNillableValue {self.randomEQType()}
    }
    
    private func randomNillableGlobalGain() -> Float? {
        randomNillableValue {self.randomGlobalGain()}
    }
    
    private func randomNillableTenBands() -> [Float]? {
        randomNillableValue {self.tenRandomBands()}
    }
    
    private func randomNillableFifteenBands() -> [Float]? {
        randomNillableValue {self.fifteenRandomBands()}
    }
    
    private let validGainRange: ClosedRange<Float> = -20...20
    
    private func randomGlobalGain() -> Float {Float.random(in: validGainRange)}
    
    private func tenRandomBands() -> [Float] {
        (0..<10).map {_ in Float.random(in: validGainRange)}
    }
    
    private func fifteenRandomBands() -> [Float] {
        (0..<15).map {_ in Float.random(in: validGainRange)}
    }
    
    private func validatePersistentState(persistentState: EQUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [EQPresetPersistentState]?,
                                         type: EQType?, globalGain: Float?, bands: [Float]?) {
        
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
        
        XCTAssertEqual(persistentState.type, type)
        AssertEqual(persistentState.globalGain, globalGain, accuracy: 0.001)
        AssertEqual(persistentState.bands, bands, accuracy: 0.001)
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
