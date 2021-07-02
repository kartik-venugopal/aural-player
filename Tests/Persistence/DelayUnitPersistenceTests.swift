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

class DelayUnitPersistenceTests: AuralTestCase {
    
    func testDeserialization_defaultSettings() {

        doTestDeserialization(state: AudioGraphDefaults.delayState, userPresets: [],
                              amount: AudioGraphDefaults.delayAmount,
                              time: AudioGraphDefaults.delayTime,
                              feedback: AudioGraphDefaults.delayFeedback,
                              lowPassCutoff: AudioGraphDefaults.delayLowPassCutoff)
    }
    
    func testDeserialization_noValuesAvailable() {
        
        doTestDeserialization(state: nil, userPresets: nil, amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
    }
    
    func testDeserialization_someValuesAvailable() {

        doTestDeserialization(state: .active, userPresets: [], amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
        
        doTestDeserialization(state: .active, userPresets: [], amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
        
        doTestDeserialization(state: .bypassed, userPresets: [], amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
        
        doTestDeserialization(state: .bypassed, userPresets: [], amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
        
        doTestDeserialization(state: .suppressed, userPresets: [], amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
        
        doTestDeserialization(state: .suppressed, userPresets: [], amount: nil,
                              time: nil, feedback: nil, lowPassCutoff: nil)
        
        for _ in 0..<100 {

            doTestDeserialization(state: randomNillableUnitState(), userPresets: [],
                                  amount: randomNillableAmount(),
                                  time: randomNillableTime(), feedback: randomNillableFeedback(),
                                  lowPassCutoff: randomNillableLowPassCutoff())
        }
    }
    
    func testDeserialization_active_noPresets() {

        for _ in 0..<100 {

            doTestDeserialization(state: .active, userPresets: [],
                                  amount: randomAmount(), time: randomTime(),
                                  feedback: randomFeedback(), lowPassCutoff: randomLowPassCutoff())
        }
    }

    func testDeserialization_bypassed_noPresets() {

        for _ in 0..<100 {

            doTestDeserialization(state: .bypassed, userPresets: [],
                                  amount: randomAmount(), time: randomTime(),
                                  feedback: randomFeedback(), lowPassCutoff: randomLowPassCutoff())
        }
    }

    func testDeserialization_suppressed_noPresets() {

        for _ in 0..<100 {

            doTestDeserialization(state: .suppressed, userPresets: [],
                                  amount: randomAmount(), time: randomTime(),
                                  feedback: randomFeedback(), lowPassCutoff: randomLowPassCutoff())
        }
    }
    
    func testDeserialization_active_withPresets() {

        for _ in 0..<100 {

            let numPresets = Int.random(in: 1...10)
            let presets: [DelayPresetPersistentState] = (0..<numPresets).map {index in

                DelayPresetPersistentState(preset: DelayPreset("preset-\(index)", .active,
                                                                 randomAmount(), randomTime(),
                                                                 randomFeedback(), randomLowPassCutoff(),
                                                                 false))
            }

            doTestDeserialization(state: .active, userPresets: presets,
                                  amount: randomAmount(), time: randomTime(),
                                  feedback: randomFeedback(), lowPassCutoff: randomLowPassCutoff())
        }
    }
    
    private func doTestDeserialization(state: EffectsUnitState?, userPresets: [DelayPresetPersistentState]?,
                                       amount: Float?, time: Double?,
                                       feedback: Float?, lowPassCutoff: Float?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = state?.rawValue
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
        
        XCTAssertEqual(persistentState.state, state)
        
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
        
        XCTAssertEqual(persistentState.amount, amount)
        XCTAssertEqual(persistentState.time, time)
        XCTAssertEqual(persistentState.feedback, feedback)
        XCTAssertEqual(persistentState.lowPassCutoff, lowPassCutoff)
    }
    
    // MARK: Helper functions --------------------------------------------

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
}

// MARK: Equality comparison for model objects -----------------------------

extension DelayPresetPersistentState: Equatable {
    
    static func == (lhs: DelayPresetPersistentState, rhs: DelayPresetPersistentState) -> Bool {
        
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.amount == rhs.amount
            && lhs.time == rhs.time && lhs.feedback == rhs.feedback && lhs.lowPassCutoff == rhs.lowPassCutoff
    }
}
