//
//  SoundProfilePersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class SoundProfilePersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence() {
        
        for _ in 0..<100 {
            
            doTestPersistence(file: randomFile(),
                              volume: randomVolume(),
                              balance: randomBalance(),
                              effects: randomMasterPresets(count: 1)[0])
        }
    }
    
    private func doTestPersistence(file: URLPath, volume: Float,
                                   balance: Float, effects: MasterPresetPersistentState) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = SoundProfilePersistentState(file: file,
                                                          volume: volume,
                                                          balance: balance,
                                                          effects: effects)
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: SoundProfilePersistentState.self) else {
            
            XCTFail("persistentState is nil, init of EQUnit state failed.")
            return
        }

        XCTAssertEqual(deserializedState.file, file)
        AssertEqual(deserializedState.volume, volume, accuracy: 0.001)
        AssertEqual(deserializedState.balance, balance, accuracy: 0.001)
        XCTAssertEqual(deserializedState.effects, effects)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension SoundProfilePersistentState: Equatable {
    
    static func == (lhs: SoundProfilePersistentState, rhs: SoundProfilePersistentState) -> Bool {
        
        lhs.file == rhs.file && lhs.volume == rhs.volume && lhs.balance == rhs.balance
            && lhs.effects == rhs.effects
    }
}
