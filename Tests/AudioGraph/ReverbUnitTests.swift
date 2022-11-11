//
//  ReverbUnitTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class ReverbUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for space in ReverbSpaces.allCases {
                
                for _ in 1...1000 {
                    
                    let persistentState = ReverbUnitPersistentState(state: unitState,
                                                                    userPresets: randomReverbPresets(unitState: .active),
                                                                    space: space,
                                                                    amount: randomReverbAmount())
                    
                    doTestInit(persistentState: persistentState)
                }
            }
        }
    }
    
    private func doTestInit(persistentState: ReverbUnitPersistentState) {
        
        let reverbUnit = ReverbUnit(persistentState: persistentState)
        validate(reverbUnit, persistentState: persistentState)
    }
    
    func testToggleState() {
        
        for startingState in EffectsUnitState.allCases {
            
            let persistentState = ReverbUnitPersistentState(state: startingState, userPresets: nil, space: nil, amount: nil)
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            
            XCTAssertEqual(reverbUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = reverbUnit.state == .active ? .bypassed : .active
                let newState = reverbUnit.toggleState()
                
                XCTAssertEqual(reverbUnit.state, expectedState)
                XCTAssertEqual(newState, expectedState)
                
                XCTAssertEqual(reverbUnit.node.bypass, reverbUnit.state != .active)
            }
        }
    }
    
    func testIsActive() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = ReverbUnitPersistentState(state: startingState, userPresets: nil, space: nil, amount: nil)
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            
            XCTAssertEqual(reverbUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = reverbUnit.state == .active ? .bypassed : .active
                _ = reverbUnit.toggleState()
                
                XCTAssertEqual(reverbUnit.state, expectedState)
                XCTAssertEqual(reverbUnit.isActive, expectedState == .active)
                
                XCTAssertEqual(reverbUnit.node.bypass, !reverbUnit.isActive)
            }
        }
    }
    
    func testSuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = ReverbUnitPersistentState(state: startingState, userPresets: nil, space: nil, amount: nil)
                let reverbUnit = ReverbUnit(persistentState: persistentState)
                
                XCTAssertEqual(reverbUnit.state, startingState)
                
                let expectedState: EffectsUnitState = reverbUnit.state == .active ? .suppressed : reverbUnit.state
                reverbUnit.suppress()
                
                XCTAssertEqual(reverbUnit.state, expectedState)
                XCTAssertEqual(reverbUnit.isActive, expectedState == .active)
                
                if reverbUnit.state == .suppressed {
                    XCTAssertTrue(reverbUnit.node.bypass)
                }
            }
        }
    }
    
    func testUnsuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = ReverbUnitPersistentState(state: startingState, userPresets: nil, space: nil, amount: nil)
                let reverbUnit = ReverbUnit(persistentState: persistentState)
                
                XCTAssertEqual(reverbUnit.state, startingState)
                
                let expectedState: EffectsUnitState = reverbUnit.state == .suppressed ? .active : reverbUnit.state
                reverbUnit.unsuppress()
                
                XCTAssertEqual(reverbUnit.state, expectedState)
                XCTAssertEqual(reverbUnit.isActive, expectedState == .active)
                
                if reverbUnit.state == .active {
                    XCTAssertFalse(reverbUnit.node.bypass)
                }
            }
        }
    }
    
    func testSavePreset() {
        
        for _ in 1...1000 {
            
            let persistentState = ReverbUnitPersistentState(state: .active, userPresets: nil, space: nil, amount: nil)
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            
            XCTAssertEqual(reverbUnit.state, .active)
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            let presetName = "TestReverbPreset-1"
            reverbUnit.savePreset(named: presetName)
            
            guard let savedPreset = reverbUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save Reverb preset named \(presetName)")
                continue
            }
            
            XCTAssertEqual(savedPreset.name, presetName)
            XCTAssertEqual(savedPreset.space, reverbUnit.space)
            XCTAssertEqual(savedPreset.amount, reverbUnit.amount, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = ReverbUnitPersistentState(state: .active, userPresets: nil, space: nil, amount: nil)
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            
            XCTAssertEqual(reverbUnit.state, .active)
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            let presetName = "TestReverbPreset-1"
            reverbUnit.savePreset(named: presetName)
            
            guard let savedPreset = reverbUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save Reverb preset named \(presetName)")
                continue
            }
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            XCTAssertNotEqual(reverbUnit.amount, savedPreset.amount)
            
            reverbUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(reverbUnit.space, savedPreset.space)
            XCTAssertEqual(reverbUnit.amount, savedPreset.amount, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let persistentPresets = randomReverbPresets(count: 3, unitState: .active)
            let persistentState = ReverbUnitPersistentState(state: .active, userPresets: persistentPresets, space: nil, amount: nil)
            
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            XCTAssertEqual(reverbUnit.state, .active)
            XCTAssertEqual(reverbUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            let presetToApply = reverbUnit.presets.userDefinedPresets.randomElement()
            let presetName = presetToApply.name
            
            XCTAssertNotEqual(reverbUnit.amount, presetToApply.amount)
            
            reverbUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(reverbUnit.space, presetToApply.space)
            XCTAssertEqual(reverbUnit.amount, presetToApply.amount, accuracy: 0.001)
        }
    }
    
    func testApplyPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = ReverbUnitPersistentState(state: .active, userPresets: nil, space: nil, amount: nil)
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            
            XCTAssertEqual(reverbUnit.state, .active)
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            let presetName = "TestReverbPreset-1"
            reverbUnit.savePreset(named: presetName)
            
            guard let savedPreset = reverbUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save Reverb preset named \(presetName)")
                continue
            }
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            XCTAssertNotEqual(reverbUnit.amount, savedPreset.amount)
            
            reverbUnit.applyPreset(savedPreset)
            
            XCTAssertEqual(reverbUnit.space, savedPreset.space)
            XCTAssertEqual(reverbUnit.amount, savedPreset.amount, accuracy: 0.001)
        }
    }
    
    func testApplyPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let persistentPresets = randomReverbPresets(count: 3, unitState: .active)
            let persistentState = ReverbUnitPersistentState(state: .active, userPresets: persistentPresets, space: nil, amount: nil)
            
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            XCTAssertEqual(reverbUnit.state, .active)
            XCTAssertEqual(reverbUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            let presetToApply = reverbUnit.presets.userDefinedPresets.randomElement()
            
            XCTAssertNotEqual(reverbUnit.amount, presetToApply.amount)
            
            reverbUnit.applyPreset(presetToApply)
            
            XCTAssertEqual(reverbUnit.space, presetToApply.space)
            XCTAssertEqual(reverbUnit.amount, presetToApply.amount, accuracy: 0.001)
        }
    }
    
    func testSettingsAsPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = ReverbUnitPersistentState(state: .active, userPresets: nil, space: nil, amount: nil)
            let reverbUnit = ReverbUnit(persistentState: persistentState)
            
            XCTAssertEqual(reverbUnit.state, .active)
            
            reverbUnit.space = .randomCase()
            reverbUnit.amount = randomReverbAmount()
            
            let settingsAsPreset: ReverbPreset = reverbUnit.settingsAsPreset
            
            XCTAssertEqual(settingsAsPreset.space, reverbUnit.space)
            XCTAssertEqual(settingsAsPreset.amount, reverbUnit.amount, accuracy: 0.001)
        }
    }
    
    func testSpace() {
        
        let reverbUnit = ReverbUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let space = ReverbSpaces.randomCase()
            reverbUnit.space = space
            
            XCTAssertEqual(reverbUnit.space, space)
        }
    }
    
    func testAmount() {
        
        let reverbUnit = ReverbUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let amount = randomReverbAmount()
            doTestAmount(amount, withUnit: reverbUnit)
        }
        
        // Special values
        for amount: Float in [0, 50, 100] {
            doTestAmount(amount, withUnit: reverbUnit)
        }
    }
    
    private func doTestAmount(_ amount: Float, withUnit reverbUnit: ReverbUnit) {
        
        reverbUnit.amount = amount
        
        XCTAssertEqual(reverbUnit.amount, amount, accuracy: 0.001)
        XCTAssertEqual(reverbUnit.node.wetDryMix, amount, accuracy: 0.001)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ReverbPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: ReverbPreset, rhs: ReverbPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            Float.approxEquals(lhs.amount, rhs.amount, accuracy: 0.001) &&
            lhs.space == rhs.space
    }
}
