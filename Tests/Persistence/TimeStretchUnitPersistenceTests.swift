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
class TimeStretchUnitPersistenceTests: PersistenceTestCase {
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.timeState, userPresets: [],
                              rate: AudioGraphDefaults.timeStretchRate,
                              shiftPitch: AudioGraphDefaults.timeShiftPitch,
                              overlap: AudioGraphDefaults.timeOverlap)
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil)
    }

    func testInit_someValuesAvailable() {

        doTestInit(unitState: .active, userPresets: [], rate: randomRate(), shiftPitch: nil, overlap: nil)
        
        doTestInit(unitState: .bypassed, userPresets: nil, rate: nil, shiftPitch: Bool.random(),
                              overlap: randomOverlap())
        
        doTestInit(unitState: .suppressed, userPresets: [], rate: randomRate(), shiftPitch: nil,
                              overlap: randomOverlap())

        for _ in 0..<100 {

            doTestInit(unitState: randomNillableUnitState(),
                       userPresets: randomNillablePresets(), rate: randomNillableRate(),
                       shiftPitch: randomNillableShiftPitch(), overlap: randomNillableOverlap())
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [TimeStretchPresetPersistentState]?,
                                       rate: Float?, shiftPitch: Bool?, overlap: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["rate"] = rate
        dict["shiftPitch"] = shiftPitch
        dict["overlap"] = overlap
        
        let optionalPersistentState = TimeStretchUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of TimeStretchUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets, rate: rate,
                                shiftPitch: shiftPitch, overlap: overlap)
    }

    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomPresets(), rate: randomRate(),
                                  shiftPitch: Bool.random(), overlap: randomOverlap())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [TimeStretchPresetPersistentState],
                                   rate: Float, shiftPitch: Bool, overlap: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = TimeStretchUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.rate = rate
        serializedState.shiftPitch = shiftPitch
        serializedState.overlap = overlap
        
        persistenceManager.save(serializedState)
        
        guard let persistentState = persistenceManager.load(type: TimeStretchUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of TimeStretchUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets, rate: rate,
                                shiftPitch: shiftPitch, overlap: overlap)
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func randomNillablePresets() -> [TimeStretchPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func randomPresets() -> [TimeStretchPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in

            TimeStretchPresetPersistentState(preset: TimePreset("preset-\(index)", .active,
                                                                 randomRate(), randomOverlap(),
                                                                 Bool.random(), false))
        }
    }
    
    private func randomRate() -> Float {Float.random(in: 0.25...4)}
    
    private func randomNillableRate() -> Float? {
        randomNillableValue {self.randomRate()}
    }
    
    private func randomNillableShiftPitch() -> Bool? {
        randomNillableValue {Bool.random()}
    }
    
    private func randomOverlap() -> Float {Float.random(in: 3...32)}
    
    private func randomNillableOverlap() -> Float? {
        randomNillableValue {self.randomOverlap()}
    }
    
    private func validatePersistentState(persistentState: TimeStretchUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [TimeStretchPresetPersistentState]?,
                                         rate: Float?, shiftPitch: Bool?, overlap: Float?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
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
