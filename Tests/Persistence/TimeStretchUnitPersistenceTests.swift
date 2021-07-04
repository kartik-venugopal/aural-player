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
class TimeStretchUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
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
        
        doTestInit(unitState: .active, userPresets: [], rate: randomTimeStretchRate(), shiftPitch: nil, overlap: nil)
        
        doTestInit(unitState: .bypassed, userPresets: nil, rate: nil, shiftPitch: Bool.random(),
                   overlap: randomOverlap())
        
        doTestInit(unitState: .suppressed, userPresets: [], rate: randomTimeStretchRate(), shiftPitch: nil,
                   overlap: randomOverlap())
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(),
                       userPresets: randomNillableTimeStretchPresets(unitState: .active), rate: randomNillableTimeStretchRate(),
                       shiftPitch: randomNillableTimeStretchShiftPitch(), overlap: randomNillableOverlap())
        }
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: unitState, userPresets: randomTimeStretchPresets(unitState: .active),
                           rate: randomTimeStretchRate(),
                           shiftPitch: randomTimeStretchShiftPitch(), overlap: randomOverlap())
            }
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
        
        validateTimeStretchUnitPersistentState(persistentState, unitState: unitState,
                                               userPresets: userPresets, rate: rate,
                                               shiftPitch: shiftPitch, overlap: overlap)
    }
    
    // MARK: Persistence tests -------------------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomTimeStretchPresets(unitState: .active),
                                  rate: randomTimeStretchRate(),
                                  shiftPitch: randomTimeStretchShiftPitch(), overlap: randomOverlap())
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
        
        guard let deserializedState = persistenceManager.load(type: TimeStretchUnitPersistentState.self) else {
            
            XCTFail("deserializedState is nil, deserialization of TimeStretchUnit state failed.")
            return
        }
        
        validateTimeStretchUnitPersistentState(deserializedState, unitState: unitState,
                                               userPresets: userPresets, rate: rate,
                                               shiftPitch: shiftPitch, overlap: overlap)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension TimeStretchPresetPersistentState: Equatable {
    
    static func == (lhs: TimeStretchPresetPersistentState, rhs: TimeStretchPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            lhs.rate.approxEquals(rhs.rate, accuracy: 0.001) &&
            lhs.shiftPitch == rhs.shiftPitch &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
