//
//  PitchShiftUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PitchShiftUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = PitchShiftUnitPersistentState(state: unitState,
                                                                    userPresets: randomPitchShiftPresets(unitState: .active),
                                                                    pitch: randomPitch(), overlap: randomOverlap())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    // TODO: Test with invalid / missing values in persistent state.
    
    private func doTestInit(persistentState: PitchShiftUnitPersistentState) {
        
        let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
        validate(pitchShiftUnit, persistentState: persistentState)
    }
    
    func testToggleState() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = PitchShiftUnitPersistentState(state: startingState, userPresets: nil, pitch: nil, overlap: nil)
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            
            XCTAssertEqual(pitchShiftUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = pitchShiftUnit.state == .active ? .bypassed : .active
                let newState = pitchShiftUnit.toggleState()
                
                XCTAssertEqual(pitchShiftUnit.state, expectedState)
                XCTAssertEqual(newState, expectedState)
                
                XCTAssertEqual(pitchShiftUnit.node.bypass, pitchShiftUnit.state != .active)
            }
        }
    }
    
    func testIsActive() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = PitchShiftUnitPersistentState(state: startingState, userPresets: nil, pitch: nil, overlap: nil)
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            
            XCTAssertEqual(pitchShiftUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = pitchShiftUnit.state == .active ? .bypassed : .active
                _ = pitchShiftUnit.toggleState()
                
                XCTAssertEqual(pitchShiftUnit.state, expectedState)
                XCTAssertEqual(pitchShiftUnit.isActive, expectedState == .active)
                
                XCTAssertEqual(pitchShiftUnit.node.bypass, !pitchShiftUnit.isActive)
            }
        }
    }
    
    func testSuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = PitchShiftUnitPersistentState(state: startingState, userPresets: nil, pitch: nil, overlap: nil)
                let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
                
                XCTAssertEqual(pitchShiftUnit.state, startingState)
                
                let expectedState: EffectsUnitState = pitchShiftUnit.state == .active ? .suppressed : pitchShiftUnit.state
                pitchShiftUnit.suppress()
                
                XCTAssertEqual(pitchShiftUnit.state, expectedState)
                XCTAssertEqual(pitchShiftUnit.isActive, expectedState == .active)
                
                if pitchShiftUnit.state == .suppressed {
                    XCTAssertTrue(pitchShiftUnit.node.bypass)
                }
            }
        }
    }
    
    func testUnsuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = PitchShiftUnitPersistentState(state: startingState, userPresets: nil, pitch: nil, overlap: nil)
                let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
                
                XCTAssertEqual(pitchShiftUnit.state, startingState)
                
                let expectedState: EffectsUnitState = pitchShiftUnit.state == .suppressed ? .active : pitchShiftUnit.state
                pitchShiftUnit.unsuppress()
                
                XCTAssertEqual(pitchShiftUnit.state, expectedState)
                XCTAssertEqual(pitchShiftUnit.isActive, expectedState == .active)
                
                if pitchShiftUnit.state == .active {
                    XCTAssertFalse(pitchShiftUnit.node.bypass)
                }
            }
        }
    }
    
    func testSavePreset() {
        
        for _ in 1...1000 {
            
            let persistentState = PitchShiftUnitPersistentState(state: .active, userPresets: nil, pitch: nil, overlap: nil)
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            
            XCTAssertEqual(pitchShiftUnit.state, .active)
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            let presetName = "TestPitchShiftPreset-1"
            pitchShiftUnit.savePreset(named: presetName)
            
            guard let savedPreset = pitchShiftUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save PitchShift preset named \(presetName)")
                continue
            }
            
            XCTAssertEqual(savedPreset.name, presetName)
            XCTAssertEqual(savedPreset.pitch, pitchShiftUnit.pitch, accuracy: 0.001)
            XCTAssertEqual(savedPreset.overlap, pitchShiftUnit.overlap, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = PitchShiftUnitPersistentState(state: .active, userPresets: nil, pitch: nil, overlap: nil)
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            
            XCTAssertEqual(pitchShiftUnit.state, .active)
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            let presetName = "TestPitchShiftPreset-1"
            pitchShiftUnit.savePreset(named: presetName)
            
            guard let savedPreset = pitchShiftUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save PitchShift preset named \(presetName)")
                continue
            }
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            XCTAssertNotEqual(pitchShiftUnit.pitch, savedPreset.pitch)
            XCTAssertNotEqual(pitchShiftUnit.overlap, savedPreset.overlap)
            
            pitchShiftUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(pitchShiftUnit.pitch, savedPreset.pitch, accuracy: 0.001)
            XCTAssertEqual(pitchShiftUnit.overlap, savedPreset.overlap, accuracy: 0.001)
        }
    }
    
    func testApplyNamedPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let persistentPresets = randomPitchShiftPresets(count: 3, unitState: .active)
            let persistentState = PitchShiftUnitPersistentState(state: .active, userPresets: persistentPresets, pitch: nil, overlap: nil)
            
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            XCTAssertEqual(pitchShiftUnit.state, .active)
            XCTAssertEqual(pitchShiftUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            let presetToApply = pitchShiftUnit.presets.userDefinedPresets.randomElement()
            let presetName = presetToApply.name
            
            XCTAssertNotEqual(pitchShiftUnit.pitch, presetToApply.pitch)
            XCTAssertNotEqual(pitchShiftUnit.overlap, presetToApply.overlap)
            
            pitchShiftUnit.applyPreset(named: presetName)
            
            XCTAssertEqual(pitchShiftUnit.pitch, presetToApply.pitch, accuracy: 0.001)
            XCTAssertEqual(pitchShiftUnit.overlap, presetToApply.overlap, accuracy: 0.001)
        }
    }
    
    func testApplyPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = PitchShiftUnitPersistentState(state: .active, userPresets: nil, pitch: nil, overlap: nil)
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            
            XCTAssertEqual(pitchShiftUnit.state, .active)
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            let presetName = "TestPitchShiftPreset-1"
            pitchShiftUnit.savePreset(named: presetName)
            
            guard let savedPreset = pitchShiftUnit.presets.userDefinedPreset(named: presetName) else {
                
                XCTFail("Failed to save PitchShift preset named \(presetName)")
                continue
            }
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            XCTAssertNotEqual(pitchShiftUnit.pitch, savedPreset.pitch)
            XCTAssertNotEqual(pitchShiftUnit.overlap, savedPreset.overlap)
            
            pitchShiftUnit.applyPreset(savedPreset)
            
            XCTAssertEqual(pitchShiftUnit.pitch, savedPreset.pitch, accuracy: 0.001)
            XCTAssertEqual(pitchShiftUnit.overlap, savedPreset.overlap, accuracy: 0.001)
        }
    }
    
    func testApplyPreset_persistentPreset() {
        
        for _ in 1...1000 {
            
            let persistentPresets = randomPitchShiftPresets(count: 3, unitState: .active)
            let persistentState = PitchShiftUnitPersistentState(state: .active, userPresets: persistentPresets, pitch: nil, overlap: nil)
            
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            XCTAssertEqual(pitchShiftUnit.state, .active)
            XCTAssertEqual(pitchShiftUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            let presetToApply = pitchShiftUnit.presets.userDefinedPresets.randomElement()
            
            XCTAssertNotEqual(pitchShiftUnit.pitch, presetToApply.pitch)
            XCTAssertNotEqual(pitchShiftUnit.overlap, presetToApply.overlap)
            
            pitchShiftUnit.applyPreset(presetToApply)
            
            XCTAssertEqual(pitchShiftUnit.pitch, presetToApply.pitch, accuracy: 0.001)
            XCTAssertEqual(pitchShiftUnit.overlap, presetToApply.overlap, accuracy: 0.001)
        }
    }
    
    func testSettingsAsPreset() {
        
        for _ in 1...1000 {
            
            let persistentState = PitchShiftUnitPersistentState(state: .active, userPresets: nil, pitch: nil, overlap: nil)
            let pitchShiftUnit = PitchShiftUnit(persistentState: persistentState)
            
            XCTAssertEqual(pitchShiftUnit.state, .active)
            
            pitchShiftUnit.pitch = randomPitch()
            pitchShiftUnit.overlap = randomOverlap()
            
            let settingsAsPreset: PitchShiftPreset = pitchShiftUnit.settingsAsPreset
            
            XCTAssertEqual(settingsAsPreset.pitch, pitchShiftUnit.pitch, accuracy: 0.001)
            XCTAssertEqual(settingsAsPreset.overlap, pitchShiftUnit.overlap, accuracy: 0.001)
        }
    }
    
    func testPitch() {
        
        let pitchShiftUnit = PitchShiftUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let pitch = randomPitch()
            pitchShiftUnit.pitch = pitch
            
            XCTAssertEqual(pitchShiftUnit.pitch, pitch, accuracy: 0.001)
            XCTAssertEqual(pitchShiftUnit.node.pitch, pitch, accuracy: 0.001)
        }
    }
    
    func testOverlap() {
        
        let pitchShiftUnit = PitchShiftUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let overlap = randomOverlap()
            pitchShiftUnit.overlap = overlap
            
            XCTAssertEqual(pitchShiftUnit.overlap, overlap, accuracy: 0.001)
            XCTAssertEqual(pitchShiftUnit.node.overlap, overlap, accuracy: 0.001)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PitchShiftPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: PitchShiftPreset, rhs: PitchShiftPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            Float.approxEquals(lhs.pitch, rhs.pitch, accuracy: 0.001) &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
