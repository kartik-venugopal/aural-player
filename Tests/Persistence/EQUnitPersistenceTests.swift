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
        
        doTestDeserialization(state: .active, userPresets: nil, type: nil,
                              globalGain: nil, bands: tenRandomBands())
        
        doTestDeserialization(state: .active, userPresets: nil, type: nil,
                              globalGain: nil, bands: fifteenRandomBands())
        
        doTestDeserialization(state: .bypassed, userPresets: [], type: .tenBand,
                              globalGain: nil, bands: nil)
        
        doTestDeserialization(state: .suppressed, userPresets: [], type: .fifteenBand,
                              globalGain: 2.435, bands: nil)
    }
    
    // MARK: 10 band EQ tests --------------------------------------------
    
    func testDeserialization_10BandEQ_active_noPresets() {
        
        doTestDeserialization(state: .active, userPresets: [], type: .tenBand, globalGain: 5.678,
                              bands: tenRandomBands())
    }
    
    func testDeserialization_10BandEQ_bypassed_noPresets() {
        
        doTestDeserialization(state: .bypassed, userPresets: [], type: .tenBand, globalGain: -6.817,
                              bands: tenRandomBands())
    }
    
    func testDeserialization_10BandEQ_suppressed_noPresets() {
        
        doTestDeserialization(state: .suppressed, userPresets: [], type: .tenBand, globalGain: 9.2235345,
                              bands: tenRandomBands())
    }
    
    func testDeserialization_10BandEQ_active_withPresets() {
        
        let preset1 = EQPresetPersistentState(preset: EQPreset("preset1", .active,
                                                               tenRandomBands(), 7.1111,
                                                               false))
        
        let preset2 = EQPresetPersistentState(preset: EQPreset("preset2", .active,
                                                               tenRandomBands(), 3.0932934,
                                                               false))
        
        doTestDeserialization(state: .active, userPresets: [preset1, preset2], type: .tenBand, globalGain: 2.59438,
                              bands: tenRandomBands())
    }
    
    // MARK: 15 band EQ tests --------------------------------------------
    
    func testDeserialization_15BandEQ_active_noPresets() {
        
        doTestDeserialization(state: .active, userPresets: [], type: .fifteenBand, globalGain: 5.678,
                              bands: fifteenRandomBands())
    }
    
    func testDeserialization_15BandEQ_bypassed_noPresets() {
        
        doTestDeserialization(state: .bypassed, userPresets: [], type: .fifteenBand, globalGain: -6.817,
                              bands: fifteenRandomBands())
    }
    
    func testDeserialization_15BandEQ_suppressed_noPresets() {
        
        doTestDeserialization(state: .suppressed, userPresets: [], type: .fifteenBand, globalGain: 3.66456,
                              bands: fifteenRandomBands())
    }
    
    func testDeserialization_15BandEQ_active_withPresets() {
        
        let preset1 = EQPresetPersistentState(preset: EQPreset("preset1", .active,
                                                               fifteenRandomBands(), 7.1111,
                                                               false))
        
        let preset2 = EQPresetPersistentState(preset: EQPreset("preset2", .active,
                                                               fifteenRandomBands(), 3.0932934,
                                                               false))
        
        doTestDeserialization(state: .active, userPresets: [preset1, preset2], type: .fifteenBand, globalGain: 8.23425,
                              bands: fifteenRandomBands())
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func tenRandomBands() -> [Float] {
        (0..<10).map {_ in Float.random(in: -20...20)}
    }
    
    private func fifteenRandomBands() -> [Float] {
        (0..<15).map {_ in Float.random(in: -20...20)}
    }
    
    private func doTestDeserialization(state: EffectsUnitState?, userPresets: [EQPresetPersistentState]?,
                                       type: EQType?, globalGain: Float?, bands: [Float]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = state?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["type"] = type?.rawValue
        dict["globalGain"] = globalGain
        dict["bands"] = bands
        
        print("dict is: \(dict)")
        
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
