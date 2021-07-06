//
//  PlaybackProfilesPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaybackProfilesPersistenceTests: PersistenceTestCase {
    
    func testPersistence_noProfiles() {
        doTestPersistence(serializedState: [PlaybackProfilePersistentState]())
    }
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            let numProfiles = Int.random(in: 10...100)
            
            let profiles = (1...numProfiles).map {_ in
                
                PlaybackProfilePersistentState(file: randomAudioFile(),
                                               lastPosition: randomPlaybackPosition())
            }
            
            doTestPersistence(serializedState: profiles)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PlaybackProfilePersistentState: Equatable {
    
    static func == (lhs: PlaybackProfilePersistentState, rhs: PlaybackProfilePersistentState) -> Bool {
        lhs.file == rhs.file && Double.approxEquals(lhs.lastPosition, rhs.lastPosition, accuracy: 0.001)
    }
}
