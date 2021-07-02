//
//  SequencerPersistenceTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerPersistenceTests: SequencerTests {

    func testPersistentState() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            _ = sequencer.setRepeatMode(repeatMode)
            _ = sequencer.setShuffleMode(shuffleMode)
            
            let modes = sequencer.repeatAndShuffleModes
            
            XCTAssertEqual(modes.repeatMode, repeatMode)
            XCTAssertEqual(modes.shuffleMode, shuffleMode)
            
            let persistentState = sequencer.persistentState
//            XCTAssertTrue(persistentState is PlaybackSequencePersistentState)
            
//            if let state = persistentState as? PlaybackSequencePersistentState {
                
                XCTAssertEqual(persistentState.repeatMode, modes.repeatMode)
                XCTAssertEqual(persistentState.shuffleMode, modes.shuffleMode)
//            }
        }
    }
}
