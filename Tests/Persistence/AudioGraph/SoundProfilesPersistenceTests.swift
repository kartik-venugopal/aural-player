//
//  SoundProfilesPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class SoundProfilesPersistenceTests: AudioGraphTestCase {
    
    func testPersistence_noProfiles() {
        doTestPersistence(serializedState: [SoundProfilePersistentState]())
    }
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            let numProfiles = Int.random(in: 10...100)
            
            let profiles = (1...numProfiles).map {_ in
                
                SoundProfilePersistentState(file: randomAudioFile(),
                                            volume: randomVolume(),
                                            balance: randomBalance(),
                                            effects: randomMasterPresets(count: 1)[0])
            }
            
            doTestPersistence(serializedState: profiles)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension SoundProfilePersistentState: Equatable {
    
    static func == (lhs: SoundProfilePersistentState, rhs: SoundProfilePersistentState) -> Bool {
        
        lhs.file == rhs.file && Float.approxEquals(lhs.volume, rhs.volume, accuracy: 0.001) &&
            Float.approxEquals(lhs.balance, rhs.balance, accuracy: 0.001)
            && lhs.effects == rhs.effects
    }
}
