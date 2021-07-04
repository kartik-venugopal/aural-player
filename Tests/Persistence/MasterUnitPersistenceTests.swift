//
//  MasterUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class MasterUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        doTestInit(unitState: AudioGraphDefaults.masterState, userPresets: [])
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil)
    }
    
    func testInit_someValuesAvailable() {
        doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillablePresets())
    }
    
    func testInit() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: state, userPresets: randomPresets())
            }
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [MasterPresetPersistentState]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        guard let persistentState = MasterUnitPersistentState(dict) else {
            
            XCTFail("persistentState is nil, init of EQUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets)
    }
    
    // MARK: Helper functions ---------------------------------------
    
    private func randomPresets() -> [MasterPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        if numPresets == 0 {return []}
        
        let eqPresets = randomEQPresets(count: numPresets)
        let pitchShiftPresets = randomPitchShiftPresets(count: numPresets)
        let timeStretchPresets = randomTimeStretchPresets(count: numPresets)
        let reverbPresets = randomReverbPresets(count: numPresets)
        let delayPresets = randomDelayPresets(count: numPresets)
        let filterPresets = randomFilterPresets(count: numPresets)
        
        return (0..<numPresets).map {index in
            
            let preset = MasterPreset("preset-\(index + 1)", EQPreset(persistentState: eqPresets[index]),
                                      PitchPreset(persistentState: pitchShiftPresets[index]),
                                      TimePreset(persistentState: timeStretchPresets[index]),
                                      ReverbPreset(persistentState: reverbPresets[index]),
                                      DelayPreset(persistentState: delayPresets[index]),
                                      FilterPreset(persistentState: filterPresets[index]),
                                      false)
            
            return MasterPresetPersistentState(preset: preset)
        }
    }
    
    private func randomNillablePresets() -> [MasterPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func validatePersistentState(persistentState: MasterUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [MasterPresetPersistentState]?) {
        
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
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension MasterPresetPersistentState: Equatable {
    
    static func == (lhs: MasterPresetPersistentState, rhs: MasterPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            lhs.eq == rhs.eq && lhs.pitch == rhs.pitch &&
            lhs.time == rhs.time && lhs.reverb == rhs.reverb &&
            lhs.filter == rhs.filter
    }
}
