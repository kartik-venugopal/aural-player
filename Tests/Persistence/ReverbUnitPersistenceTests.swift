//
//  ReverbUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class ReverbUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.reverbState, userPresets: [],
                   space: AudioGraphDefaults.reverbSpace,
                   amount: AudioGraphDefaults.reverbAmount)
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, space: nil, amount: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        doTestInit(unitState: .active, userPresets: [], space: randomReverbSpace(), amount: nil)
        doTestInit(unitState: .active, userPresets: [], space: nil, amount: randomReverbAmount())
        
        doTestInit(unitState: .bypassed, userPresets: [], space: randomReverbSpace(), amount: nil)
        doTestInit(unitState: .bypassed, userPresets: [], space: nil, amount: randomReverbAmount())
        
        doTestInit(unitState: .suppressed, userPresets: [], space: randomReverbSpace(), amount: nil)
        doTestInit(unitState: .suppressed, userPresets: [], space: nil, amount: randomReverbAmount())
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(),
                       userPresets: randomNillableReverbPresets(unitState: .active),
                       space: randomNillableReverbSpace(),
                       amount: randomNillableReverbAmount())
        }
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for space in ReverbSpaces.allCases {
                
                for _ in 0..<100 {
                    
                    doTestInit(unitState: unitState, userPresets: randomReverbPresets(unitState: .active),
                               space: space, amount: randomReverbAmount())
                }
            }
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [ReverbPresetPersistentState]?,
                            space: ReverbSpaces?, amount: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["space"] = space?.rawValue
        dict["amount"] = amount
        
        let optionalPersistentState = ReverbUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of ReverbUnit state failed.")
            return
        }
        
        validateReverbUnitPersistentState(persistentState, unitState: unitState, userPresets: userPresets,
                                          space: space, amount: amount)
    }
    
    // MARK:Persistence tests --------------------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for space in ReverbSpaces.allCases {
                
                for _ in 0..<100 {
                    
                    doTestInit(unitState: unitState, userPresets: randomReverbPresets(unitState: .active),
                               space: space, amount: randomReverbAmount())
                }
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [ReverbPresetPersistentState],
                                   space: ReverbSpaces, amount: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = ReverbUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.space = space
        serializedState.amount = amount
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: ReverbUnitPersistentState.self) else {
            
            XCTFail("deserializedState is nil, deserialization of ReverbUnit state failed.")
            return
        }
        
        validateReverbUnitPersistentState(deserializedState, unitState: unitState,
                                userPresets: userPresets,
                                space: space, amount: amount)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ReverbPresetPersistentState: Equatable {
    
    static func == (lhs: ReverbPresetPersistentState, rhs: ReverbPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.space == rhs.space &&
            lhs.amount.approxEquals(rhs.amount, accuracy: 0.001)
    }
}
