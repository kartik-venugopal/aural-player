//
//  DelayUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class DelayUnitPersistenceTests: PersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.delayState, userPresets: [],
                   amount: AudioGraphDefaults.delayAmount,
                   time: AudioGraphDefaults.delayTime,
                   feedback: AudioGraphDefaults.delayFeedback,
                   lowPassCutoff: AudioGraphDefaults.delayLowPassCutoff)
    }
    
    func testInit_noValuesAvailable() {
        
        doTestInit(unitState: nil, userPresets: nil, amount: nil,
                   time: nil, feedback: nil, lowPassCutoff: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        for unitState in EffectsUnitState.allCases {
            
            doTestInit(unitState: unitState, userPresets: randomNillablePresets(),
                       amount: randomNillableAmount(),
                       time: randomNillableTime(), feedback: randomNillableFeedback(),
                       lowPassCutoff: randomNillableLowPassCutoff())
        }
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillablePresets(),
                       amount: randomNillableAmount(),
                       time: randomNillableTime(), feedback: randomNillableFeedback(),
                       lowPassCutoff: randomNillableLowPassCutoff())
        }
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: unitState, userPresets: randomPresets(),
                           amount: randomAmount(), time: randomTime(),
                           feedback: randomFeedback(), lowPassCutoff: randomLowPassCutoff())
            }
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [DelayPresetPersistentState]?,
                            amount: Float?, time: Double?,
                            feedback: Float?, lowPassCutoff: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["amount"] = amount
        dict["time"] = time
        dict["feedback"] = feedback
        dict["lowPassCutoff"] = lowPassCutoff
        
        let optionalPersistentState = DelayUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of DelayUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState, userPresets: userPresets,
                                amount: amount, time: time, feedback: feedback, lowPassCutoff: lowPassCutoff)
    }
    
    // MARK: Persistence tests -------------------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomPresets(),
                           amount: randomAmount(), time: randomTime(),
                           feedback: randomFeedback(), lowPassCutoff: randomLowPassCutoff())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState?, userPresets: [DelayPresetPersistentState],
                                   amount: Float, time: Double,
                                   feedback: Float, lowPassCutoff: Float) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = DelayUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.amount = amount
        serializedState.time = time
        serializedState.feedback = feedback
        serializedState.lowPassCutoff = lowPassCutoff
        
        persistenceManager.save(serializedState)
        
        guard let persistentState = persistenceManager.load(type: DelayUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of DelayUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState, userPresets: userPresets,
                                amount: amount, time: time, feedback: feedback, lowPassCutoff: lowPassCutoff)
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func randomNillablePresets() -> [DelayPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func randomPresets() -> [DelayPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            DelayPresetPersistentState(preset: DelayPreset("preset-\(index)", .active,
                                                           randomAmount(), randomTime(),
                                                           randomFeedback(), randomLowPassCutoff(),
                                                           false))
        }
    }
    
    private func randomAmount() -> Float {Float.random(in: 0...100)}
    
    private func randomNillableAmount() -> Float? {
        randomNillableValue {self.randomAmount()}
    }
    
    private func randomTime() -> Double {Double.random(in: 0...2)}
    
    private func randomNillableTime() -> Double? {
        randomNillableValue {self.randomTime()}
    }
    
    private func randomFeedback() -> Float {Float.random(in: -100...100)}
    
    private func randomNillableFeedback() -> Float? {
        randomNillableValue {self.randomFeedback()}
    }
    
    private func randomLowPassCutoff() -> Float {Float.random(in: 10...20000)}
    
    private func randomNillableLowPassCutoff() -> Float? {
        randomNillableValue {self.randomLowPassCutoff()}
    }
    
    private func validatePersistentState(persistentState: DelayUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [DelayPresetPersistentState]?,
                                         amount: Float?, time: Double?,
                                         feedback: Float?, lowPassCutoff: Float?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of DelayUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        AssertEqual(persistentState.amount, amount, accuracy: 0.001)
        AssertEqual(persistentState.time, time, accuracy: 0.001)
        AssertEqual(persistentState.feedback, feedback, accuracy: 0.001)
        AssertEqual(persistentState.lowPassCutoff, lowPassCutoff, accuracy: 0.001)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension DelayPresetPersistentState: Equatable {
    
    static func == (lhs: DelayPresetPersistentState, rhs: DelayPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state &&
            lhs.amount.approxEquals(rhs.amount, accuracy: 0.001) &&
            lhs.time.approxEquals(rhs.time, accuracy: 0.001) &&
            lhs.feedback.approxEquals(rhs.feedback, accuracy: 0.001) &&
            lhs.lowPassCutoff.approxEquals(rhs.lowPassCutoff, accuracy: 0.001)
    }
}
