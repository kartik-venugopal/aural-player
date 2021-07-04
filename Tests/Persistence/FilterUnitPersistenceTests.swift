//
//  FilterUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FilterUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.filterState, userPresets: [],
                   bands: [])
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, bands: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        for state in EffectsUnitState.allCases {
            
            doTestInit(unitState: state, userPresets: randomNillableFilterPresets(unitState: .active),
                       bands: randomNillableFilterBands())
        }
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillableFilterPresets(unitState: .active),
                       bands: randomNillableFilterBands())
        }
    }
    
    func testInit() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: state, userPresets: randomFilterPresets(unitState: .active),
                           bands: randomFilterBands())
            }
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [FilterPresetPersistentState]?,
                            bands: [FilterBandPersistentState]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["bands"] = bands == nil ? nil : NSArray(array: bands!.map {JSONMapper.map($0)})
        
        let optionalPersistentState = FilterUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of FilterUnit state failed.")
            return
        }
        
        validateFilterUnitPersistentState(persistentState: persistentState, unitState: unitState,
                                          userPresets: userPresets, bands: bands)
    }
    
    // MARK: Persistence tests -------------------------------------------
    
    func testPersistence() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomFilterPresets(unitState: .active),
                                  bands: randomFilterBands())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [FilterPresetPersistentState],
                                   bands: [FilterBandPersistentState]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = FilterUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.bands = bands
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: FilterUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of FilterUnit state failed.")
            return
        }
        
        validateFilterUnitPersistentState(persistentState: deserializedState, unitState: unitState,
                                          userPresets: userPresets, bands: bands)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FilterPresetPersistentState: Equatable {
    
    static func == (lhs: FilterPresetPersistentState, rhs: FilterPresetPersistentState) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.bands == rhs.bands
    }
}

extension FilterBandPersistentState: Equatable {
    
    static func == (lhs: FilterBandPersistentState, rhs: FilterBandPersistentState) -> Bool {
        
        lhs.type == rhs.type &&
            Float.approxEquals(lhs.minFreq, rhs.minFreq, accuracy: 0.001) &&
            Float.approxEquals(lhs.maxFreq, rhs.maxFreq, accuracy: 0.001)
    }
}
