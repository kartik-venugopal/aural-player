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

class ReverbUnitPersistenceTests: PersistenceTestCase {
    
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
        
        doTestInit(unitState: .active, userPresets: [], space: randomSpace(), amount: nil)
        doTestInit(unitState: .active, userPresets: [], space: nil, amount: randomAmount())
        
        doTestInit(unitState: .bypassed, userPresets: [], space: randomSpace(), amount: nil)
        doTestInit(unitState: .bypassed, userPresets: [], space: nil, amount: randomAmount())
        
        doTestInit(unitState: .suppressed, userPresets: [], space: randomSpace(), amount: nil)
        doTestInit(unitState: .suppressed, userPresets: [], space: nil, amount: randomAmount())
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(),
                       userPresets: randomNillablePresets(),
                       space: randomNillableSpace(),
                       amount: randomNillableAmount())
        }
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for space in ReverbSpaces.allCases {
                
                for _ in 0..<100 {
                    
                    doTestInit(unitState: unitState, userPresets: randomPresets(),
                               space: space, amount: randomAmount())
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
        
        XCTAssertEqual(persistentState.state, unitState)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of ReverbUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.space, space)
        XCTAssertEqual(persistentState.amount, amount)
    }
    
    // MARK:Persistence tests --------------------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for space in ReverbSpaces.allCases {
                
                for _ in 0..<100 {
                    
                    doTestInit(unitState: unitState, userPresets: randomPresets(),
                               space: space, amount: randomAmount())
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
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState,
                                userPresets: userPresets,
                                space: space, amount: amount)
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func randomNillablePresets() -> [ReverbPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func randomPresets() -> [ReverbPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            ReverbPresetPersistentState(preset: ReverbPreset("preset-\(index)", .active,
                                                             randomSpace(), randomAmount(),
                                                             false))
        }
    }
    
    private func randomSpace() -> ReverbSpaces {ReverbSpaces.randomCase()}
    
    private func randomNillableSpace() -> ReverbSpaces? {
        randomNillableValue {self.randomSpace()}
    }
    
    private func randomAmount() -> Float {Float.random(in: 0...100)}
    
    private func randomNillableAmount() -> Float? {
        randomNillableValue {self.randomAmount()}
    }
    
    private func validatePersistentState(persistentState: ReverbUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [ReverbPresetPersistentState]?,
                                         space: ReverbSpaces?, amount: Float?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of ReverbUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.space, space)
        AssertEqual(persistentState.amount, amount, accuracy: 0.001)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ReverbPresetPersistentState: Equatable {
    
    static func == (lhs: ReverbPresetPersistentState, rhs: ReverbPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.space == rhs.space &&
            lhs.amount.approxEquals(rhs.amount, accuracy: 0.001)
    }
}
