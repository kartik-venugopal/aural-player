//
//  PitchShiftUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

///
/// Unit tests for **PitchShiftUnitPersistentState**.
///
class PitchShiftUnitPersistenceTests: AuralTestCase {
    
    func testDeserialization_defaultSettings() {
        
        doTestDeserialization(state: AudioGraphDefaults.pitchState, userPresets: [],
                              pitch: AudioGraphDefaults.pitch,
                              overlap: AudioGraphDefaults.pitchOverlap)
    }
    
    func testDeserialization_noValuesAvailable() {
        doTestDeserialization(state: nil, userPresets: nil, pitch: nil, overlap: nil)
    }
    
    func testDeserialization_someValuesAvailable() {
        
        doTestDeserialization(state: .active, userPresets: [], pitch: nil, overlap: 7.345)
        doTestDeserialization(state: .bypassed, userPresets: nil, pitch: 1.12314, overlap: 17.345)
        doTestDeserialization(state: nil, userPresets: [], pitch: nil, overlap: 21.5673)
        doTestDeserialization(state: nil, userPresets: nil, pitch: 1.12314, overlap: nil)
    }
    
    private func doTestDeserialization(state: EffectsUnitState?, userPresets: [PitchShiftPresetPersistentState]?,
                                       pitch: Float?, overlap: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = state?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["pitch"] = pitch
        dict["overlap"] = overlap
        
        let optionalPersistentState = PitchShiftUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of PitchShiftUnit state failed.")
            return
        }
        
        XCTAssertEqual(persistentState.state, state)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of PitchShiftUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.pitch, pitch)
        XCTAssertEqual(persistentState.overlap, overlap)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PitchShiftPresetPersistentState: Equatable {
    
    static func == (lhs: PitchShiftPresetPersistentState, rhs: PitchShiftPresetPersistentState) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.pitch == rhs.pitch && lhs.overlap == rhs.overlap
    }
}
