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
