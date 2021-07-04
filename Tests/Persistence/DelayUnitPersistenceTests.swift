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

class DelayUnitPersistenceTests: AudioGraphPersistenceTestCase {
    
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
            
            doTestInit(unitState: unitState, userPresets: randomNillableDelayPresets(unitState: .active),
                       amount: randomNillableDelayAmount(),
                       time: randomNillableDelayTime(), feedback: randomNillableDelayFeedback(),
                       lowPassCutoff: randomNillableDelayLowPassCutoff())
        }
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillableDelayPresets(unitState: .active),
                       amount: randomNillableDelayAmount(),
                       time: randomNillableDelayTime(), feedback: randomNillableDelayFeedback(),
                       lowPassCutoff: randomNillableDelayLowPassCutoff())
        }
    }
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: unitState, userPresets: randomDelayPresets(unitState: .active),
                           amount: randomDelayAmount(), time: randomDelayTime(),
                           feedback: randomDelayFeedback(), lowPassCutoff: randomDelayLowPassCutoff())
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
        
        validateDelayUnitPersistentState(persistentState, unitState: unitState, userPresets: userPresets,
                                amount: amount, time: time, feedback: feedback, lowPassCutoff: lowPassCutoff)
    }
    
    // MARK: Persistence tests -------------------------------------------
    
    func testPersistence() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: unitState, userPresets: randomDelayPresets(unitState: .active),
                           amount: randomDelayAmount(), time: randomDelayTime(),
                           feedback: randomDelayFeedback(), lowPassCutoff: randomDelayLowPassCutoff())
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
        
        validateDelayUnitPersistentState(persistentState, unitState: unitState, userPresets: userPresets,
                                amount: amount, time: time, feedback: feedback, lowPassCutoff: lowPassCutoff)
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
