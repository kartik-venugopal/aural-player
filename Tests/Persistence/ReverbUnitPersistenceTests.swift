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

class ReverbUnitPersistenceTests: AuralTestCase {
    
    func testDeserialization_defaultSettings() {
        
        doTestDeserialization(state: AudioGraphDefaults.reverbState, userPresets: [],
                              space: AudioGraphDefaults.reverbSpace,
                              amount: AudioGraphDefaults.reverbAmount)
    }
    
    func testDeserialization_noValuesAvailable() {
        doTestDeserialization(state: nil, userPresets: nil, space: nil, amount: nil)
    }

    func testDeserialization_someValuesAvailable() {

        doTestDeserialization(state: .active, userPresets: [], space: randomSpace(), amount: nil)
        doTestDeserialization(state: .active, userPresets: [], space: nil, amount: randomAmount())
        
        doTestDeserialization(state: .bypassed, userPresets: [], space: randomSpace(), amount: nil)
        doTestDeserialization(state: .bypassed, userPresets: [], space: nil, amount: randomAmount())
        
        doTestDeserialization(state: .suppressed, userPresets: [], space: randomSpace(), amount: nil)
        doTestDeserialization(state: .suppressed, userPresets: [], space: nil, amount: randomAmount())
        
        for _ in 0..<100 {

            doTestDeserialization(state: randomNillableUnitState(),
                                  userPresets: [],
                                  space: randomSpace(),
                                  amount: randomAmount())
        }
    }
    
    func testDeserialization_active_noPresets() {

        for space in ReverbSpaces.allCases {

            doTestDeserialization(state: .active, userPresets: [],
                                  space: space, amount: randomAmount())
        }
    }

    func testDeserialization_bypassed_noPresets() {

        for space in ReverbSpaces.allCases {

            doTestDeserialization(state: .bypassed, userPresets: [],
                                  space: space, amount: randomAmount())
        }
    }

    func testDeserialization_suppressed_noPresets() {

        for space in ReverbSpaces.allCases {

            doTestDeserialization(state: .suppressed, userPresets: [],
                                  space: space, amount: randomAmount())
        }
    }
    
    func testDeserialization_active_withPresets() {

        for space in ReverbSpaces.allCases {

            let numPresets = Int.random(in: 1...10)
            let presets: [ReverbPresetPersistentState] = (0..<numPresets).map {index in

                ReverbPresetPersistentState(preset: ReverbPreset("preset-\(index)", .active,
                                                                 randomSpace(), randomAmount(),
                                                                 false))
            }

            doTestDeserialization(state: .active, userPresets: presets,
                                  space: space, amount: randomAmount())
        }
    }
    
    private func doTestDeserialization(state: EffectsUnitState?, userPresets: [ReverbPresetPersistentState]?,
                                       space: ReverbSpaces?, amount: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = state?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["space"] = space?.rawValue
        dict["amount"] = amount
        
        let optionalPersistentState = ReverbUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of ReverbUnit state failed.")
            return
        }
        
        XCTAssertEqual(persistentState.state, state)
        
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
    
    // MARK: Helper functions --------------------------------------------

    private func randomSpace() -> ReverbSpaces {ReverbSpaces.randomCase()}

    private let amountRange: ClosedRange<Float> = 0...100

    private func randomAmount() -> Float {Float.random(in: amountRange)}

    private func randomNillableAmount() -> Float? {
        
        if Float.random(in: 0...1) < 0.5 {
            return randomAmount()
        } else {
            return nil
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ReverbPresetPersistentState: Equatable {
    
    static func == (lhs: ReverbPresetPersistentState, rhs: ReverbPresetPersistentState) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.space == rhs.space && lhs.amount == rhs.amount
    }
}
