//
//  TimeStretchUnitPersistentState.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

///
/// Unit tests for **TimeStretchUnitPersistentState**.
///
class TimeStretchUnitPersistenceTests: AuralTestCase {
    
    func testDeserialization_defaultSettings() {
        
        doTestDeserialization(state: AudioGraphDefaults.timeState, userPresets: [],
                              rate: AudioGraphDefaults.timeStretchRate,
                              shiftPitch: AudioGraphDefaults.timeShiftPitch,
                              overlap: AudioGraphDefaults.timeOverlap)
    }
    
    func testDeserialization_noValuesAvailable() {
        doTestDeserialization(state: nil, userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil)
    }

    func testDeserialization_someValuesAvailable() {

        doTestDeserialization(state: .active, userPresets: [], rate: randomRate(), shiftPitch: nil, overlap: nil)
        
        doTestDeserialization(state: .bypassed, userPresets: nil, rate: nil, shiftPitch: Bool.random(),
                              overlap: randomOverlap())
        
        doTestDeserialization(state: .suppressed, userPresets: [], rate: randomRate(), shiftPitch: nil,
                              overlap: randomOverlap())

        for _ in 0..<100 {

            doTestDeserialization(state: randomNillableUnitState(),
                                  userPresets: [], rate: randomNillableRate(),
                                  shiftPitch: randomNillableShiftPitch(),
                                  overlap: randomNillableOverlap())
        }
    }

    func testDeserialization_active_noPresets() {

        for _ in 0..<100 {

            doTestDeserialization(state: .active, userPresets: [], rate: randomRate(),
                                  shiftPitch: Bool.random(), overlap: randomOverlap())
        }
    }

    func testDeserialization_bypassed_noPresets() {

        for _ in 0..<100 {

            doTestDeserialization(state: .bypassed, userPresets: [], rate: randomRate(),
                                  shiftPitch: Bool.random(), overlap: randomOverlap())
        }
    }

    func testDeserialization_suppressed_noPresets() {

        for _ in 0..<100 {

            doTestDeserialization(state: .suppressed, userPresets: [], rate: randomRate(),
                                  shiftPitch: Bool.random(), overlap: randomOverlap())
        }
    }

    func testDeserialization_active_withPresets() {

        for _ in 0..<100 {

            let numPresets = Int.random(in: 1...10)
            let presets: [TimeStretchPresetPersistentState] = (0..<numPresets).map {index in

                TimeStretchPresetPersistentState(preset: TimePreset("preset-\(index)", .active,
                                                                     randomRate(), randomOverlap(),
                                                                     Bool.random(), false))
            }

            doTestDeserialization(state: .active, userPresets: presets,
                                  rate: randomRate(), shiftPitch: Bool.random(), overlap: randomOverlap())
        }
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private let rateRange: ClosedRange<Float> = 0.25...4
    
    private func randomRate() -> Float {Float.random(in: rateRange)}
    
    private func randomNillableRate() -> Float? {
        
        if Float.random(in: 0...1) < 0.5 {
            return randomRate()
        } else {
            return nil
        }
    }
    
    private func randomNillableShiftPitch() -> Bool? {
        
        if Float.random(in: 0...1) < 0.5 {
            return Bool.random()
        } else {
            return nil
        }
    }
    
    private func randomOverlap() -> Float {Float.random(in: 3...32)}
    
    private func randomNillableOverlap() -> Float? {
        
        if Float.random(in: 0...1) < 0.5 {
            return randomOverlap()
        } else {
            return nil
        }
    }
    
    private func doTestDeserialization(state: EffectsUnitState?, userPresets: [TimeStretchPresetPersistentState]?,
                                       rate: Float?, shiftPitch: Bool?, overlap: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = state?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["rate"] = rate
        dict["shiftPitch"] = shiftPitch
        dict["overlap"] = overlap
        
        let optionalPersistentState = TimeStretchUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of TimeStretchUnit state failed.")
            return
        }
        
        XCTAssertEqual(persistentState.state, state)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of TimeStretchUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.rate, rate)
        XCTAssertEqual(persistentState.shiftPitch, shiftPitch)
        XCTAssertEqual(persistentState.overlap, overlap)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension TimeStretchPresetPersistentState: Equatable {
    
    static func == (lhs: TimeStretchPresetPersistentState, rhs: TimeStretchPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.rate == rhs.rate &&
            lhs.shiftPitch == rhs.shiftPitch && lhs.overlap == rhs.overlap
    }
}
