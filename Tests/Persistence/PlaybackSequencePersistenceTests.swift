//
//  PlaybackSequencePersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaybackSequencePersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for repeatMode in RepeatMode.allCases {
            
            for shuffleMode in ShuffleMode.allCases {
                
                let state = PlaybackSequencePersistentState(repeatMode: repeatMode,
                                                            shuffleMode: shuffleMode)
                
                doTestPersistence(serializedState: state)
            }
        }
        
        for _ in 1...1000 {
            
            let state = PlaybackSequencePersistentState(repeatMode: RepeatMode.randomCase(),
                                                        shuffleMode: ShuffleMode.randomCase())
            
            doTestPersistence(serializedState: state)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PlaybackSequencePersistentState: Equatable {
    
    static func == (lhs: PlaybackSequencePersistentState, rhs: PlaybackSequencePersistentState) -> Bool {
        lhs.repeatMode == rhs.repeatMode && lhs.shuffleMode == rhs.shuffleMode
    }
}
