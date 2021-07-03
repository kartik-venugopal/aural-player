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
class PitchShiftUnitPersistenceTests: PersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.pitchState, userPresets: [],
                              pitch: AudioGraphDefaults.pitch,
                              overlap: AudioGraphDefaults.pitchOverlap)
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, pitch: nil, overlap: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        doTestInit(unitState: .active, userPresets: [], pitch: nil, overlap: randomOverlap())
        doTestInit(unitState: .bypassed, userPresets: nil, pitch: randomPitch(), overlap: randomOverlap())
        doTestInit(unitState: .suppressed, userPresets: nil, pitch: nil, overlap: randomOverlap())
        
        doTestInit(unitState: nil, userPresets: [], pitch: nil, overlap: randomOverlap())
        doTestInit(unitState: nil, userPresets: nil, pitch: randomPitch(), overlap: nil)
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(),
                                  userPresets: randomNillablePresets(),
                                  pitch: randomNillablePitch(),
                                  overlap: randomNillableOverlap())
        }
    }
    
    // MARK: Persistence tests ---------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomPresets(),
                                  pitch: randomPitch(), overlap: randomOverlap())
            }
        }
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func randomNillablePresets() -> [PitchShiftPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func randomPresets() -> [PitchShiftPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            PitchShiftPresetPersistentState(preset: PitchPreset("preset-\(index)", .active,
                                                                randomPitch(), randomOverlap(),
                                                                false))
        }
    }
    
    private func randomPitch() -> Float {Float.random(in: -2400...2400)}
    
    private func randomNillablePitch() -> Float? {
        randomNillableValue {self.randomPitch()}
    }
    
    private func randomPositivePitch() -> Float {Float.random(in: 0...2400)}
    
    private func randomNegativePitch() -> Float {Float.random(in: -2400..<0)}
    
    private func randomOverlap() -> Float {Float.random(in: 3...32)}
    
    private func randomNillableOverlap() -> Float? {
        randomNillableValue {self.randomOverlap()}
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [PitchShiftPresetPersistentState]?,
                                       pitch: Float?, overlap: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["pitch"] = pitch
        dict["overlap"] = overlap
        
        let optionalPersistentState = PitchShiftUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of PitchShiftUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets, pitch: pitch, overlap: overlap)
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [PitchShiftPresetPersistentState],
                                   pitch: Float, overlap: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = PitchShiftUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.pitch = pitch
        serializedState.overlap = overlap
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: PitchShiftUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of PitchShiftUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState,
                                userPresets: userPresets, pitch: pitch, overlap: overlap)
    }
    
    private func validatePersistentState(persistentState: PitchShiftUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [PitchShiftPresetPersistentState]?,
                                         pitch: Float?, overlap: Float?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
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
