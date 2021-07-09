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
        
        XCTAssertEqual(pitchShiftUnit.state, persistentState.state)
        XCTAssertEqual(pitchShiftUnit.node.bypass, pitchShiftUnit.state != .active)
        
        XCTAssertEqual(pitchShiftUnit.pitch, persistentState.pitch!, accuracy: 0.001)
        XCTAssertEqual(pitchShiftUnit.node.pitch, persistentState.pitch!, accuracy: 0.001)
        
        XCTAssertEqual(pitchShiftUnit.overlap, persistentState.overlap!, accuracy: 0.001)
        XCTAssertEqual(pitchShiftUnit.node.overlap, persistentState.overlap!, accuracy: 0.001)
        
        let expectedPresets = Set(persistentState.userPresets!.map {PitchShiftPreset(persistentState: $0)})
        XCTAssertEqual(Set(pitchShiftUnit.presets.userDefinedPresets), expectedPresets)
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
