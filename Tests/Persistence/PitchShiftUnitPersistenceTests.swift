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
        
        doTestDeserialization(state: .active, userPresets: [], pitch: nil, overlap: randomOverlap())
        doTestDeserialization(state: .bypassed, userPresets: nil, pitch: randomPitch(), overlap: randomOverlap())
        doTestDeserialization(state: nil, userPresets: [], pitch: nil, overlap: randomOverlap())
        doTestDeserialization(state: nil, userPresets: nil, pitch: randomPitch(), overlap: nil)
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: randomNillableUnitState(),
                                  userPresets: [],
                                  pitch: randomNillablePitch(),
                                  overlap: randomNillableOverlap())
        }
    }
    
    func testDeserialization_active_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .active, userPresets: [],
                                  pitch: randomPositivePitch(),
                                  overlap: randomOverlap())
            
            doTestDeserialization(state: .active, userPresets: [],
                                  pitch: randomNegativePitch(),
                                  overlap: randomOverlap())
        }
    }
    
    func testDeserialization_bypassed_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .bypassed, userPresets: [],
                                  pitch: randomPositivePitch(),
                                  overlap: randomOverlap())
            
            doTestDeserialization(state: .suppressed, userPresets: [],
                                  pitch: randomNegativePitch(),
                                  overlap: randomOverlap())
        }
    }
    
    func testDeserialization_suppressed_noPresets() {
        
        for _ in 0..<100 {
            
            doTestDeserialization(state: .suppressed, userPresets: [],
                                  pitch: randomPositivePitch(),
                                  overlap: randomOverlap())
            
            doTestDeserialization(state: .suppressed, userPresets: [],
                                  pitch: randomNegativePitch(),
                                  overlap: randomOverlap())
        }
    }
    
    func testDeserialization_active_withPresets() {
        
        for _ in 0..<100 {
            
            let numPresets = Int.random(in: 1...10)
            let presets: [PitchShiftPresetPersistentState] = (0..<numPresets).map {index in
                
                PitchShiftPresetPersistentState(preset: PitchPreset("preset-\(index)", .active,
                                                         randomPitch(), randomOverlap(),
                                                         false))
            }
            
            doTestDeserialization(state: .active, userPresets: presets,
                                  pitch: randomPitch(), overlap: randomOverlap())
        }
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private let pitchRange: ClosedRange<Float> = -2400...2400
    
    private func randomPitch() -> Float {Float.random(in: pitchRange)}
    
    private func randomNillablePitch() -> Float? {
        
        if Float.random(in: 0...1) < 0.5 {
            return randomPitch()
        } else {
            return nil
        }
    }
    
    private func randomPositivePitch() -> Float {Float.random(in: 0...2400)}
    
    private func randomNegativePitch() -> Float {Float.random(in: -2400..<0)}
    
    private func randomOverlap() -> Float {Float.random(in: 3...32)}
    
    private func randomNillableOverlap() -> Float? {
        
        if Float.random(in: 0...1) < 0.5 {
            return randomOverlap()
        } else {
            return nil
        }
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
