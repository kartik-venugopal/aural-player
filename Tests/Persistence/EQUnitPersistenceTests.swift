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
class EQUnitPersistenceTests: AuralTestCase {
    
    func testDeserialization_defaultSettings() {
        
        doTestDeserialization(state: AudioGraphDefaults.eqState, userPresets: [],
                              type: AudioGraphDefaults.eqType,
                              globalGain: AudioGraphDefaults.eqGlobalGain,
                              bands: AudioGraphDefaults.eqBands)
    }
    
    func testDeserialization_noValuesAvailable() {
        doTestDeserialization(state: nil, userPresets: nil, type: nil, globalGain: nil, bands: nil)
    }
    
    func testDeserialization_someValuesAvailable() {
        
        doTestDeserialization(state: .active, userPresets: nil, type: nil,
                              globalGain: nil, bands: nil)
        
        doTestDeserialization(state: .bypassed, userPresets: nil, type: nil,
                              globalGain: nil, bands: nil)
        
        doTestDeserialization(state: .suppressed, userPresets: nil, type: nil,
                              globalGain: nil, bands: nil)
        
        doTestDeserialization(state: .active, userPresets: nil, type: nil,
                              globalGain: nil, bands: tenRandomBands())
        
        doTestDeserialization(state: .active, userPresets: nil, type: nil,
                              globalGain: nil, bands: fifteenRandomBands())
        
        doTestDeserialization(state: .bypassed, userPresets: [], type: .tenBand,
                              globalGain: randomGlobalGain(), bands: nil)
        
        doTestDeserialization(state: .suppressed, userPresets: [], type: .fifteenBand,
                              globalGain: randomGlobalGain(), bands: nil)
        
        for _ in 0..<100 {
            
            let eqType = randomNillableEQType()
            
            doTestDeserialization(state: randomNillableUnitState(), userPresets: [],
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
    
    func testDeserialization_10BandEQ_active_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .active, userPresets: [], type: .tenBand, globalGain: randomGlobalGain(),
                                  bands: tenRandomBands())
            
        }
    }
    
    func testDeserialization_10BandEQ_bypassed_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .bypassed, userPresets: [], type: .tenBand, globalGain: randomGlobalGain(),
                                  bands: tenRandomBands())
        }
    }
    
    func testDeserialization_10BandEQ_suppressed_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .suppressed, userPresets: [], type: .tenBand, globalGain: randomGlobalGain(),
                                  bands: tenRandomBands())
        }
    }
    
    func testDeserialization_10BandEQ_active_withPresets() {
        
        for _ in 0..<100 {
            
            let numPresets = Int.random(in: 1...10)
            let presets: [EQPresetPersistentState] = (0..<numPresets).map {index in
                
                
                EQPresetPersistentState(preset: EQPreset("preset-\(index)", .active,
                                                         tenRandomBands(), randomGlobalGain(),
                                                         false))
            }
            
            doTestDeserialization(state: .active, userPresets: presets, type: .tenBand,
                                  globalGain: randomGlobalGain(), bands: tenRandomBands())
        }
    }
    
    // MARK: 15 band EQ tests --------------------------------------------
    
    func testDeserialization_15BandEQ_active_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .active, userPresets: [], type: .fifteenBand,
                                  globalGain: randomGlobalGain(), bands: fifteenRandomBands())
        }
    }
    
    func testDeserialization_15BandEQ_bypassed_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .bypassed, userPresets: [], type: .fifteenBand,
                                  globalGain: randomGlobalGain(), bands: fifteenRandomBands())
        }
    }
    
    func testDeserialization_15BandEQ_suppressed_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .suppressed, userPresets: [], type: .fifteenBand,
                                  globalGain: randomGlobalGain(), bands: fifteenRandomBands())
        }
    }
    
    func testDeserialization_15BandEQ_active_withPresets() {
        
        for _ in 0..<100 {
            
            let numPresets = Int.random(in: 1...10)
            let presets: [EQPresetPersistentState] = (0..<numPresets).map {index in
                
                
                EQPresetPersistentState(preset: EQPreset("preset-\(index)", .active,
                                                         fifteenRandomBands(), randomGlobalGain(),
                                                         false))
            }
            
            doTestDeserialization(state: .active, userPresets: presets, type: .fifteenBand,
                                  globalGain: randomGlobalGain(), bands: fifteenRandomBands())
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
    
    private func doTestDeserialization(state: EffectsUnitState?, userPresets: [EQPresetPersistentState]?,
                                       type: EQType?, globalGain: Float?, bands: [Float]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = state?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["type"] = type?.rawValue
        dict["globalGain"] = globalGain
        dict["bands"] = bands
        
        let optionalPersistentState = EQUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of EQUnit state failed.")
            return
        }
        
        XCTAssertEqual(persistentState.state, state)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of EQUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.type, type)
        XCTAssertEqual(persistentState.globalGain, globalGain)
        XCTAssertEqual(persistentState.bands, bands)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension EQPresetPersistentState: Equatable {
    
    static func == (lhs: EQPresetPersistentState, rhs: EQPresetPersistentState) -> Bool {
        lhs.state == rhs.state && lhs.name == rhs.name && lhs.bands == rhs.bands && lhs.globalGain == rhs.globalGain
    }
}
