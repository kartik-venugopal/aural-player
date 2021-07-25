//
//  DelayUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class DelayUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = DelayUnitPersistentState(state: unitState,
                                                               userPresets: randomDelayPresets(unitState: .active),
                                                               amount: randomDelayAmount(),
                                                               time: randomDelayTime(),
                                                               feedback: randomDelayFeedback(),
                                                               lowPassCutoff: randomDelayLowPassCutoff())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    private func doTestInit(persistentState: DelayUnitPersistentState) {
        
        let delayUnit = DelayUnit(persistentState: persistentState)
        validate(delayUnit, persistentState: persistentState)
    }
    
    func testToggleState() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = DelayUnitPersistentState(state: startingState, userPresets: nil,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            
            XCTAssertEqual(delayUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = delayUnit.state == .active ? .bypassed : .active
                let newState = delayUnit.toggleState()
                
                XCTAssertEqual(delayUnit.state, expectedState)
                XCTAssertEqual(newState, expectedState)
                
                XCTAssertEqual(delayUnit.node.bypass, delayUnit.state != .active)
            }
        }
    }
    
    func testIsActive() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = DelayUnitPersistentState(state: startingState, userPresets: nil,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            
            XCTAssertEqual(delayUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = delayUnit.state == .active ? .bypassed : .active
                _ = delayUnit.toggleState()
                
                XCTAssertEqual(delayUnit.state, expectedState)
                XCTAssertEqual(delayUnit.isActive, expectedState == .active)
                
                XCTAssertEqual(delayUnit.node.bypass, !delayUnit.isActive)
            }
        }
    }
    
    func testSuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = DelayUnitPersistentState(state: startingState, userPresets: nil,
                                                               amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
                
                let delayUnit = DelayUnit(persistentState: persistentState)
                
                XCTAssertEqual(delayUnit.state, startingState)
                
                let expectedState: EffectsUnitState = delayUnit.state == .active ? .suppressed : delayUnit.state
                delayUnit.suppress()
                
                XCTAssertEqual(delayUnit.state, expectedState)
                XCTAssertEqual(delayUnit.isActive, expectedState == .active)
                
                if delayUnit.state == .suppressed {
                    XCTAssertTrue(delayUnit.node.bypass)
                }
            }
        }
    }
    
    func testUnsuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = DelayUnitPersistentState(state: startingState, userPresets: nil,
                                                               amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
                
                let delayUnit = DelayUnit(persistentState: persistentState)
                
                XCTAssertEqual(delayUnit.state, startingState)
                
                let expectedState: EffectsUnitState = delayUnit.state == .suppressed ? .active : delayUnit.state
                delayUnit.unsuppress()
                
                XCTAssertEqual(delayUnit.state, expectedState)
                XCTAssertEqual(delayUnit.isActive, expectedState == .active)
                
                if delayUnit.state == .active {
                    XCTAssertFalse(delayUnit.node.bypass)
                }
            }
        }
    }
    
    func testSavePreset() {
        
        for _ in 1...1000 {
            
            let persistentState = DelayUnitPersistentState(state: .active, userPresets: nil,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            
            XCTAssertEqual(delayUnit.state, .active)
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            let presetName = "TestDelayPreset-1"
            delayUnit.savePreset(named: presetName)
            
            guard let savedPreset = delayUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save Delay preset named \(presetName)")
                continue
            }
            
            XCTAssertEqual(savedPreset.name, presetName)
            
            XCTAssertEqual(savedPreset.amount, delayUnit.amount, accuracy: 0.001)
            XCTAssertEqual(savedPreset.time, delayUnit.time, accuracy: 0.001)
            XCTAssertEqual(savedPreset.feedback, delayUnit.feedback, accuracy: 0.001)
            XCTAssertEqual(savedPreset.lowPassCutoff, delayUnit.lowPassCutoff, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = DelayUnitPersistentState(state: .active, userPresets: nil,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            
            XCTAssertEqual(delayUnit.state, .active)
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            let presetName = "TestDelayPreset-1"
            delayUnit.savePreset(named: presetName)
            
            guard let savedPreset = delayUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save Delay preset named \(presetName)")
                continue
            }
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            XCTAssertNotEqual(delayUnit.amount, savedPreset.amount)
            XCTAssertNotEqual(delayUnit.time, savedPreset.time)
            XCTAssertNotEqual(delayUnit.feedback, savedPreset.feedback)
            XCTAssertNotEqual(delayUnit.lowPassCutoff, savedPreset.lowPassCutoff)
            
            delayUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(delayUnit.amount, savedPreset.amount, accuracy: 0.001)
            XCTAssertEqual(delayUnit.time, savedPreset.time, accuracy: 0.001)
            XCTAssertEqual(delayUnit.feedback, savedPreset.feedback, accuracy: 0.001)
            XCTAssertEqual(delayUnit.lowPassCutoff, savedPreset.lowPassCutoff, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let persistentPresets = randomDelayPresets(count: 3, unitState: .active)
            let persistentState = DelayUnitPersistentState(state: .active, userPresets: persistentPresets,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            XCTAssertEqual(delayUnit.state, .active)
            XCTAssertEqual(delayUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            let presetToApply = delayUnit.presets.userDefinedPresets.randomElement()
            let presetName = presetToApply.name
            
            XCTAssertNotEqual(delayUnit.amount, presetToApply.amount)
            XCTAssertNotEqual(delayUnit.time, presetToApply.time)
            XCTAssertNotEqual(delayUnit.feedback, presetToApply.feedback)
            XCTAssertNotEqual(delayUnit.lowPassCutoff, presetToApply.lowPassCutoff)
            
            delayUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(delayUnit.amount, presetToApply.amount, accuracy: 0.001)
            XCTAssertEqual(delayUnit.time, presetToApply.time, accuracy: 0.001)
            XCTAssertEqual(delayUnit.feedback, presetToApply.feedback, accuracy: 0.001)
            XCTAssertEqual(delayUnit.lowPassCutoff, presetToApply.lowPassCutoff, accuracy: 0.001)
        }
    }
    
    func testApplyPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = DelayUnitPersistentState(state: .active, userPresets: nil,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            
            XCTAssertEqual(delayUnit.state, .active)
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            let presetName = "TestDelayPreset-1"
            delayUnit.savePreset(named: presetName)
            
            guard let savedPreset = delayUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save Delay preset named \(presetName)")
                continue
            }
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            XCTAssertNotEqual(delayUnit.amount, savedPreset.amount)
            XCTAssertNotEqual(delayUnit.time, savedPreset.time)
            XCTAssertNotEqual(delayUnit.feedback, savedPreset.feedback)
            XCTAssertNotEqual(delayUnit.lowPassCutoff, savedPreset.lowPassCutoff)
            
            delayUnit.applyPreset(savedPreset)
            
            XCTAssertEqual(delayUnit.amount, savedPreset.amount, accuracy: 0.001)
            XCTAssertEqual(delayUnit.time, savedPreset.time, accuracy: 0.001)
            XCTAssertEqual(delayUnit.feedback, savedPreset.feedback, accuracy: 0.001)
            XCTAssertEqual(delayUnit.lowPassCutoff, savedPreset.lowPassCutoff, accuracy: 0.001)
        }
    }
    
    func testApplyPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let persistentPresets = randomDelayPresets(count: 3, unitState: .active)
            let persistentState = DelayUnitPersistentState(state: .active, userPresets: persistentPresets,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            XCTAssertEqual(delayUnit.state, .active)
            XCTAssertEqual(delayUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            let presetToApply = delayUnit.presets.userDefinedPresets.randomElement()
            
            XCTAssertNotEqual(delayUnit.amount, presetToApply.amount)
            XCTAssertNotEqual(delayUnit.time, presetToApply.time)
            XCTAssertNotEqual(delayUnit.feedback, presetToApply.feedback)
            XCTAssertNotEqual(delayUnit.lowPassCutoff, presetToApply.lowPassCutoff)
            
            delayUnit.applyPreset(presetToApply)
            
            XCTAssertEqual(delayUnit.amount, presetToApply.amount, accuracy: 0.001)
            XCTAssertEqual(delayUnit.time, presetToApply.time, accuracy: 0.001)
            XCTAssertEqual(delayUnit.feedback, presetToApply.feedback, accuracy: 0.001)
            XCTAssertEqual(delayUnit.lowPassCutoff, presetToApply.lowPassCutoff, accuracy: 0.001)
        }
    }
    
    func testSettingsAsPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = DelayUnitPersistentState(state: .active, userPresets: nil,
                                                           amount: nil, time: nil, feedback: nil, lowPassCutoff: nil)
            
            let delayUnit = DelayUnit(persistentState: persistentState)
            
            XCTAssertEqual(delayUnit.state, .active)
            
            delayUnit.amount = randomDelayAmount()
            delayUnit.time = randomDelayTime()
            delayUnit.feedback = randomDelayFeedback()
            delayUnit.lowPassCutoff = randomDelayLowPassCutoff()
            
            let settingsAsPreset: DelayPreset = delayUnit.settingsAsPreset
            
            XCTAssertEqual(settingsAsPreset.amount, delayUnit.amount, accuracy: 0.001)
            XCTAssertEqual(settingsAsPreset.time, delayUnit.time, accuracy: 0.001)
            XCTAssertEqual(settingsAsPreset.feedback, delayUnit.feedback, accuracy: 0.001)
            XCTAssertEqual(settingsAsPreset.lowPassCutoff, delayUnit.lowPassCutoff, accuracy: 0.001)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension DelayPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: DelayPreset, rhs: DelayPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001) &&
            Double.approxEquals(lhs.time, rhs.time, accuracy: 0.001) &&
            Float.approxEquals(lhs.feedback, rhs.feedback, accuracy: 0.001) &&
            Float.approxEquals(lhs.lowPassCutoff, rhs.lowPassCutoff, accuracy: 0.001)
    }
}
