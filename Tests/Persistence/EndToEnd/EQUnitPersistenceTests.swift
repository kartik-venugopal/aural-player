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

class EQUnitPersistenceTests: AuralTestCase {
    
    private let persistenceManager: PersistenceManager = PersistenceManager(persistentStateFile:
                                                                                FileManager.default.temporaryDirectory.appendingPathComponent("test-state-\(UUID().uuidString).json"))
    override func tearDown() {
        persistenceManager.persistentStateFile.delete()
    }
    
    func testPersistence_defaultSettings() {
        
        doTestPersistence(state: AudioGraphDefaults.eqState, userPresets: [],
                          type: AudioGraphDefaults.eqType,
                          globalGain: AudioGraphDefaults.eqGlobalGain,
                          bands: AudioGraphDefaults.eqBands)
    }
    
    func testPersistence_noValuesAvailable() {
        doTestPersistence(state: nil, userPresets: nil, type: nil, globalGain: nil, bands: nil)
    }
    
    func testPersistence_someValuesAvailable() {
        
        doTestPersistence(state: .active, userPresets: nil, type: nil,
                          globalGain: nil, bands: nil)
        
        doTestPersistence(state: .bypassed, userPresets: nil, type: nil,
                          globalGain: nil, bands: nil)
        
        doTestPersistence(state: .suppressed, userPresets: nil, type: nil,
                          globalGain: nil, bands: nil)
        
        doTestPersistence(state: .active, userPresets: nil, type: nil,
                          globalGain: nil, bands: tenRandomBands())
        
        doTestPersistence(state: .active, userPresets: nil, type: nil,
                          globalGain: nil, bands: fifteenRandomBands())
        
        doTestPersistence(state: .bypassed, userPresets: [], type: .tenBand,
                          globalGain: randomGlobalGain(), bands: nil)
        
        doTestPersistence(state: .suppressed, userPresets: [], type: .fifteenBand,
                          globalGain: randomGlobalGain(), bands: nil)
        
        for _ in 0..<100 {
            
            let eqType = randomNillableEQType()
            
            doTestPersistence(state: randomNillableUnitState(), userPresets: [],
                              type: eqType,
                              globalGain: randomNillableGlobalGain(),
                              bands: eqType == EQType.tenBand ?
                                randomNillableTenBands() : randomNillableFifteenBands())
        }
    }
    
    // TODO:
    //    func testEQBandsAndTypeMismatch() {
    //
    //    }
    
    // MARK: 10 band EQ tests --------------------------------------------
    
    func testPersistence_10BandEQ_noPresets() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(state: state, userPresets: [], type: .tenBand, globalGain: randomGlobalGain(),
                                  bands: tenRandomBands())
                
            }
        }
    }
    
    func testPersistence_10BandEQ_withPresets() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                let numPresets = Int.random(in: 1...10)
                let presets: [EQPresetPersistentState] = (0..<numPresets).map {index in
                    
                    EQPresetPersistentState(preset: EQPreset("preset-\(index)", .active,
                                                             tenRandomBands(), randomGlobalGain(),
                                                             false))
                }
                
                doTestPersistence(state: state, userPresets: presets, type: .tenBand,
                                  globalGain: randomGlobalGain(), bands: tenRandomBands())
            }
        }
    }
    
    // MARK: 15 band EQ tests --------------------------------------------
    
    func testPersistence_15BandEQ_noPresets() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(state: state, userPresets: [], type: .fifteenBand,
                                  globalGain: randomGlobalGain(), bands: fifteenRandomBands())
            }
        }
    }
    
    func testPersistence_15BandEQ_active_withPresets() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                let numPresets = Int.random(in: 1...10)
                let presets: [EQPresetPersistentState] = (0..<numPresets).map {index in
                    
                    EQPresetPersistentState(preset: EQPreset("preset-\(index)", .active,
                                                             fifteenRandomBands(), randomGlobalGain(),
                                                             false))
                }
                
                doTestPersistence(state: state, userPresets: presets, type: .fifteenBand,
                                  globalGain: randomGlobalGain(), bands: fifteenRandomBands())
            }
        }
    }
    
    // MARK: Helper functions --------------------------------------------
    
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
    
    private func doTestPersistence(state: EffectsUnitState?, userPresets: [EQPresetPersistentState]?,
                                   type: EQType?, globalGain: Float?, bands: [Float]?) {
        
        let serializedState = EQUnitPersistentState()
        
        serializedState.state = state
        serializedState.type = type
        serializedState.bands = bands
        serializedState.globalGain = globalGain
        serializedState.userPresets = userPresets
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: EQUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of EQUnit state failed.")
            return
        }
        
        XCTAssertEqual(deserializedState.state, state)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = deserializedState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of EQUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, userPresets)
            
        } else {
            
            XCTAssertNil(deserializedState.userPresets)
        }
        
        XCTAssertEqual(deserializedState.type, type)
        XCTAssertEqual(deserializedState.globalGain, globalGain)
        XCTAssertEqual(deserializedState.bands, bands)
    }
    
}
