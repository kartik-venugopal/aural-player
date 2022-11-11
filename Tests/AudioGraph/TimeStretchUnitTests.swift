//
//  TimeStretchUnitTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class TimeStretchUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = TimeStretchUnitPersistentState(state: unitState,
                                                                     userPresets: randomTimeStretchPresets(unitState: .active),
                                                                     rate: randomTimeStretchRate(),
                                                                     shiftPitch: randomTimeStretchShiftPitch(),
                                                                     overlap: randomOverlap())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    // TODO: Test with invalid / missing values in persistent state.
    
    private func doTestInit(persistentState: TimeStretchUnitPersistentState) {
        
        let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
        validate(timeStretchUnit, persistentState: persistentState)
    }
    
    func testToggleState() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = TimeStretchUnitPersistentState(state: startingState, userPresets: nil, rate: nil,
                                                                 shiftPitch: randomTimeStretchShiftPitch(), overlap: nil)
            
            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
            
            XCTAssertEqual(timeStretchUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = timeStretchUnit.state == .active ? .bypassed : .active
                let newState = timeStretchUnit.toggleState()
                
                XCTAssertEqual(timeStretchUnit.state, expectedState)
                XCTAssertEqual(newState, expectedState)
                
                XCTAssertEqual(timeStretchUnit.node.bypass, timeStretchUnit.state != .active)
                XCTAssertEqual(timeStretchUnit.node.varispeedNode.bypass, !(timeStretchUnit.state == .active && timeStretchUnit.shiftPitch))
                XCTAssertEqual(timeStretchUnit.node.timePitchNode.bypass, timeStretchUnit.state != .active || timeStretchUnit.shiftPitch)
            }
        }
    }
    
    func testIsActive() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = TimeStretchUnitPersistentState(state: startingState, userPresets: nil, rate: nil,
                                                                 shiftPitch: randomTimeStretchShiftPitch(), overlap: nil)
            
            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
            
            XCTAssertEqual(timeStretchUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = timeStretchUnit.state == .active ? .bypassed : .active
                _ = timeStretchUnit.toggleState()
                
                XCTAssertEqual(timeStretchUnit.state, expectedState)
                XCTAssertEqual(timeStretchUnit.isActive, expectedState == .active)
                
                XCTAssertEqual(timeStretchUnit.node.bypass, !timeStretchUnit.isActive)
                XCTAssertEqual(timeStretchUnit.node.varispeedNode.bypass, !(timeStretchUnit.isActive && timeStretchUnit.shiftPitch))
                XCTAssertEqual(timeStretchUnit.node.timePitchNode.bypass, (!timeStretchUnit.isActive) || timeStretchUnit.shiftPitch)
            }
        }
    }
    
    func testSuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = TimeStretchUnitPersistentState(state: startingState, userPresets: nil, rate: nil,
                                                                     shiftPitch: randomTimeStretchShiftPitch(), overlap: nil)
                
                let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
                
                XCTAssertEqual(timeStretchUnit.state, startingState)
                
                let expectedState: EffectsUnitState = timeStretchUnit.state == .active ? .suppressed : timeStretchUnit.state
                timeStretchUnit.suppress()
                
                XCTAssertEqual(timeStretchUnit.state, expectedState)
                XCTAssertEqual(timeStretchUnit.isActive, expectedState == .active)
                
                if timeStretchUnit.state == .suppressed {
                    
                    XCTAssertTrue(timeStretchUnit.node.bypass)
                    XCTAssertTrue(timeStretchUnit.node.varispeedNode.bypass)
                    XCTAssertTrue(timeStretchUnit.node.timePitchNode.bypass)
                }
            }
        }
    }
    
    func testUnsuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = TimeStretchUnitPersistentState(state: startingState, userPresets: nil, rate: nil,
                                                                     shiftPitch: randomTimeStretchShiftPitch(), overlap: nil)
                
                let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
                
                XCTAssertEqual(timeStretchUnit.state, startingState)
                
                let expectedState: EffectsUnitState = timeStretchUnit.state == .suppressed ? .active : timeStretchUnit.state
                timeStretchUnit.unsuppress()
                
                XCTAssertEqual(timeStretchUnit.state, expectedState)
                XCTAssertEqual(timeStretchUnit.isActive, expectedState == .active)
                
                if timeStretchUnit.state == .active {
                    
                    XCTAssertFalse(timeStretchUnit.node.bypass)
                    XCTAssertEqual(timeStretchUnit.node.varispeedNode.bypass, !timeStretchUnit.shiftPitch)
                    XCTAssertEqual(timeStretchUnit.node.timePitchNode.bypass, timeStretchUnit.shiftPitch)
                }
            }
        }
    }
    
    func testSavePreset() {

        for _ in 1...1000 {

            let persistentState = TimeStretchUnitPersistentState(state: .active, userPresets: nil, rate: nil,
                                                                 shiftPitch: nil, overlap: nil)

            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)

            XCTAssertEqual(timeStretchUnit.state, .active)

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            let presetName = "TestTimeStretchPreset-1"
            timeStretchUnit.savePreset(named: presetName)

            guard let savedPreset = timeStretchUnit.presets.userDefinedPreset(named: presetName) else {

                XCTFail("Failed to save TimeStretch preset named \(presetName)")
                continue
            }

            XCTAssertEqual(savedPreset.name, presetName)
            
            XCTAssertEqual(savedPreset.rate, timeStretchUnit.rate, accuracy: 0.001)
            XCTAssertEqual(savedPreset.overlap, timeStretchUnit.overlap, accuracy: 0.001)
            XCTAssertEqual(savedPreset.shiftPitch, timeStretchUnit.shiftPitch)
        }
    }

    func testApplyNamedPreset() {

        for _ in 1...1000 {

            let persistentState = TimeStretchUnitPersistentState(state: .active, userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil)
            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)

            XCTAssertEqual(timeStretchUnit.state, .active)

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            let presetName = "TestTimeStretchPreset-1"
            timeStretchUnit.savePreset(named: presetName)

            guard let savedPreset = timeStretchUnit.presets.userDefinedPreset(named: presetName) else {

                XCTFail("Failed to save TimeStretch preset named \(presetName)")
                continue
            }

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            XCTAssertNotEqual(timeStretchUnit.rate, savedPreset.rate)
            XCTAssertNotEqual(timeStretchUnit.overlap, savedPreset.overlap)

            timeStretchUnit.applyPreset(named: presetName)

            XCTAssertEqual(timeStretchUnit.rate, savedPreset.rate, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.overlap, savedPreset.overlap, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.shiftPitch, savedPreset.shiftPitch)
        }
    }

    func testApplyNamedPreset_persistentPreset() {

        for _ in 1...1000 {

            let persistentPresets = randomTimeStretchPresets(count: 3, unitState: .active)
            let persistentState = TimeStretchUnitPersistentState(state: .active, userPresets: persistentPresets, rate: nil, shiftPitch: nil,
                                                                 overlap: nil)

            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
            XCTAssertEqual(timeStretchUnit.state, .active)
            XCTAssertEqual(timeStretchUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            let presetToApply = timeStretchUnit.presets.userDefinedPresets.randomElement()
            let presetName = presetToApply.name

            XCTAssertNotEqual(timeStretchUnit.rate, presetToApply.rate)
            XCTAssertNotEqual(timeStretchUnit.overlap, presetToApply.overlap)

            timeStretchUnit.applyPreset(named: presetName)

            XCTAssertEqual(timeStretchUnit.rate, presetToApply.rate, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.overlap, presetToApply.overlap, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.shiftPitch, presetToApply.shiftPitch)
        }
    }

    func testApplyPreset() {

        for _ in 1...1000 {

            let persistentState = TimeStretchUnitPersistentState(state: .active, userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil)
            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)

            XCTAssertEqual(timeStretchUnit.state, .active)

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            let presetName = "TestTimeStretchPreset-1"
            timeStretchUnit.savePreset(named: presetName)

            guard let savedPreset = timeStretchUnit.presets.userDefinedPreset(named: presetName) else {

                XCTFail("Failed to save TimeStretch preset named \(presetName)")
                continue
            }

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            XCTAssertNotEqual(timeStretchUnit.rate, savedPreset.rate)
            XCTAssertNotEqual(timeStretchUnit.overlap, savedPreset.overlap)

            timeStretchUnit.applyPreset(savedPreset)

            XCTAssertEqual(timeStretchUnit.rate, savedPreset.rate, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.overlap, savedPreset.overlap, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.shiftPitch, savedPreset.shiftPitch)
        }
    }

    func testApplyPreset_persistentPreset() {

        for _ in 1...1000 {

            let persistentPresets = randomTimeStretchPresets(count: 3, unitState: .active)
            let persistentState = TimeStretchUnitPersistentState(state: .active, userPresets: persistentPresets, rate: nil, shiftPitch: nil,
                                                                 overlap: nil)

            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)
            XCTAssertEqual(timeStretchUnit.state, .active)
            XCTAssertEqual(timeStretchUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            let presetToApply = timeStretchUnit.presets.userDefinedPresets.randomElement()

            XCTAssertNotEqual(timeStretchUnit.rate, presetToApply.rate)
            XCTAssertNotEqual(timeStretchUnit.overlap, presetToApply.overlap)

            timeStretchUnit.applyPreset(presetToApply)

            XCTAssertEqual(timeStretchUnit.rate, presetToApply.rate, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.overlap, presetToApply.overlap, accuracy: 0.001)
            XCTAssertEqual(timeStretchUnit.shiftPitch, presetToApply.shiftPitch)
        }
    }

    func testSettingsAsPreset() {

        for _ in 1...1000 {

            let persistentState = TimeStretchUnitPersistentState(state: .active, userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil)
            let timeStretchUnit = TimeStretchUnit(persistentState: persistentState)

            XCTAssertEqual(timeStretchUnit.state, .active)

            timeStretchUnit.rate = randomTimeStretchRate()
            timeStretchUnit.overlap = randomOverlap()
            timeStretchUnit.shiftPitch = randomTimeStretchShiftPitch()

            let settingsAsPreset: TimeStretchPreset = timeStretchUnit.settingsAsPreset

            XCTAssertEqual(settingsAsPreset.rate, timeStretchUnit.rate, accuracy: 0.001)
            XCTAssertEqual(settingsAsPreset.overlap, timeStretchUnit.overlap, accuracy: 0.001)
            XCTAssertEqual(settingsAsPreset.shiftPitch, timeStretchUnit.shiftPitch)
        }
    }
    
    func testRate() {
        
        let timeStretchUnit = TimeStretchUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let rate = randomTimeStretchRate()
            doTestRate(rate, withUnit: timeStretchUnit)
        }
    }
    
    private func doTestRate(_ rate: Float, withUnit timeStretchUnit: TimeStretchUnit) {
        
        timeStretchUnit.rate = rate
        timeStretchUnit.shiftPitch = .random()
        
        XCTAssertEqual(timeStretchUnit.rate, rate, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.rate, rate, accuracy: 0.001)
        
        XCTAssertEqual(timeStretchUnit.node.varispeedNode.rate, rate, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.timePitchNode.rate, rate, accuracy: 0.001)
    }
    
    func testOverlap() {
        
        let timeStretchUnit = TimeStretchUnit(persistentState: nil)
        
        for _ in 1...1000 {
            
            let overlap = randomOverlap()
            doTestOverlap(overlap, withUnit: timeStretchUnit)
        }
    }
    
    private func doTestOverlap(_ overlap: Float, withUnit timeStretchUnit: TimeStretchUnit) {
        
        timeStretchUnit.overlap = overlap
        
        XCTAssertEqual(timeStretchUnit.overlap, overlap, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.overlap, overlap, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.timePitchNode.overlap, overlap, accuracy: 0.001)
    }
    
    func testShiftPitch() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let timeStretchUnit = TimeStretchUnit(persistentState: TimeStretchUnitPersistentState(state: startingState,
                                                                                                      userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil))
                
                XCTAssertEqual(timeStretchUnit.state, startingState)
                
                let shiftPitch = randomTimeStretchShiftPitch()
                timeStretchUnit.shiftPitch = shiftPitch
                
                XCTAssertEqual(timeStretchUnit.shiftPitch, shiftPitch)
                XCTAssertEqual(timeStretchUnit.node.shiftPitch, shiftPitch)
                
                XCTAssertEqual(timeStretchUnit.node.bypass, startingState != .active)
                XCTAssertEqual(timeStretchUnit.node.varispeedNode.bypass, !(startingState == .active && shiftPitch))
                XCTAssertEqual(timeStretchUnit.node.timePitchNode.bypass, startingState != .active || shiftPitch)
            }
        }
    }
    
    private static let octavesToCents: Float = 1200
    
    func testPitch() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let timeStretchUnit = TimeStretchUnit(persistentState: TimeStretchUnitPersistentState(state: startingState,
                                                                                                      userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil))
                
                XCTAssertEqual(timeStretchUnit.state, startingState)
                
                let rate = randomTimeStretchRate()
                let shiftPitch = randomTimeStretchShiftPitch()
                
                doTestPitch(rate: rate, shiftPitch: shiftPitch, withUnit: timeStretchUnit)
            }
        }
        
        for startingState in EffectsUnitState.allCases {
            
            let timeStretchUnit = TimeStretchUnit(persistentState: TimeStretchUnitPersistentState(state: startingState,
                                                                                                  userPresets: nil, rate: nil, shiftPitch: nil, overlap: nil))
            
            XCTAssertEqual(timeStretchUnit.state, startingState)
            
            for (rate, shiftPitch): (Float, Bool) in permute([0.25, 0.5, 0.75, 1, 1.5, 2, 2.5, 3, 3.5, 4], [false, true]) {
                doTestPitch(rate: rate, shiftPitch: shiftPitch, withUnit: timeStretchUnit)
            }
        }
    }
    
    private func doTestPitch(rate: Float, shiftPitch: Bool, withUnit timeStretchUnit: TimeStretchUnit) {
        
        timeStretchUnit.rate = rate
        timeStretchUnit.shiftPitch = shiftPitch
        
        XCTAssertEqual(timeStretchUnit.rate, rate, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.shiftPitch, shiftPitch)
        XCTAssertEqual(timeStretchUnit.node.shiftPitch, shiftPitch)
        
        let expectedPitch = shiftPitch ? Self.octavesToCents * log2(rate) : 0
        XCTAssertEqual(timeStretchUnit.pitch, expectedPitch, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.pitch, expectedPitch, accuracy: 0.001)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension TimeStretchPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: TimeStretchPreset, rhs: TimeStretchPreset) -> Bool {
        
        lhs.state == rhs.state && lhs.name == rhs.name &&
            Float.approxEquals(lhs.rate, rhs.rate, accuracy: 0.001) &&
            Float.approxEquals(lhs.overlap, rhs.overlap, accuracy: 0.001)
    }
}
