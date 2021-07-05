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
    
    func testPersistence() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                doTestPersistence(unitState: state, userPresets: randomPresets())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [MasterPresetPersistentState]) {
        
        defer {persistenceManager.persistentStateFile.delete()}
        
        let serializedState = MasterUnitPersistentState(state: unitState, userPresets: userPresets)
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: MasterUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, init of EQUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState,
                                userPresets: userPresets)
    }
    
    // MARK: Helper functions ---------------------------------------
    
    private func randomPresets() -> [MasterPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        if numPresets == 0 {return []}
        
        let eqPresets = randomEQPresets(count: numPresets).compactMap {EQPreset(persistentState: $0)}
        let pitchShiftPresets = randomPitchShiftPresets(count: numPresets).compactMap {PitchPreset(persistentState: $0)}
        let timeStretchPresets = randomTimeStretchPresets(count: numPresets).compactMap {TimePreset(persistentState: $0)}
        let reverbPresets = randomReverbPresets(count: numPresets).compactMap {ReverbPreset(persistentState: $0)}
        let delayPresets = randomDelayPresets(count: numPresets).compactMap {DelayPreset(persistentState: $0)}
        let filterPresets = randomFilterPresets(count: numPresets).compactMap {FilterPreset(persistentState: $0)}
        
        return (0..<numPresets).map {index in
            
            let preset = MasterPreset("preset-\(index + 1)", eqPresets[index],
                                      pitchShiftPresets[index],
                                      timeStretchPresets[index],
                                      reverbPresets[index],
                                      delayPresets[index],
                                      filterPresets[index],
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
