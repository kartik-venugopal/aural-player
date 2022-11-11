//
//  SequencerRepeatAndShuffleTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerRepeatAndShuffleTests: SequencerTests {

    // MARK: toggleRepeatMode() tests ----------------------------------------------------------------------------
    
    func testToggleRepeatMode() {
        
        doTestToggleRepeatMode(.off, .off, .one, .off)
        doTestToggleRepeatMode(.off, .on, .one, .off)
        
        doTestToggleRepeatMode(.one, .off, .all, .off)
        
        doTestToggleRepeatMode(.all, .off, .off, .off)
        doTestToggleRepeatMode(.all, .on, .off, .on)
    }
    
    private func doTestToggleRepeatMode(_ repeatModeBeforeToggle: RepeatMode, _ shuffleModeBeforeToggle: ShuffleMode,
                                        _ expectedRepeatModeAfterToggle: RepeatMode, _ expectedShuffleModeAfterToggle: ShuffleMode) {
        
        _ = sequencer.setShuffleMode(shuffleModeBeforeToggle)
        let modes = sequencer.setRepeatMode(repeatModeBeforeToggle)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBeforeToggle)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBeforeToggle)
        
        let modesAfterToggle = sequencer.toggleRepeatMode()
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfterToggle, expectedShuffleModeAfterToggle))
    }
    
    func testSetRepeatMode() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            for newRepeatMode in RepeatMode.allCases {
                
                // When the new repeat mode is .one, the new shuffle mode must be .off because
                // repeat one and shuffle on cannot be set simultaneously; they are mutually exclusive
                doTestSetRepeatMode(repeatMode, shuffleMode, newRepeatMode, newRepeatMode == .one ? .off : shuffleMode)
            }
        }
    }
    
    private func doTestSetRepeatMode(_ repeatModeBefore: RepeatMode, _ shuffleModeBefore: ShuffleMode,
                                     _ newRepeatMode: RepeatMode, _ expectedShuffleModeAfter: ShuffleMode) {
        
        _ = sequencer.setShuffleMode(shuffleModeBefore)
        let modes = sequencer.setRepeatMode(repeatModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequencer.setRepeatMode(newRepeatMode)
        XCTAssertTrue(modesAfterToggle == (newRepeatMode, expectedShuffleModeAfter))
    }
    
    // MARK: toggleShuffleMode() tests ----------------------------------------------------------------------------
    
    func testToggleShuffleMode() {
        
        doTestToggleShuffleMode(.off, .off, .off, .on)
        doTestToggleShuffleMode(.off, .on, .off, .off)
        
        // Repeat one should be disabled when shuffle is turned on.
        doTestToggleShuffleMode(.one, .off, .off, .on)
        
        doTestToggleShuffleMode(.all, .off, .all, .on)
        doTestToggleShuffleMode(.all, .on, .all, .off)
    }
    
    private func doTestToggleShuffleMode(_ repeatModeBeforeToggle: RepeatMode, _ shuffleModeBeforeToggle: ShuffleMode,
                                        _ expectedRepeatModeAfterToggle: RepeatMode, _ expectedShuffleModeAfterToggle: ShuffleMode) {
        
        _ = sequencer.setRepeatMode(repeatModeBeforeToggle)
        let modes = sequencer.setShuffleMode(shuffleModeBeforeToggle)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBeforeToggle)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBeforeToggle)
        
        let modesAfterToggle = sequencer.toggleShuffleMode()
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfterToggle, expectedShuffleModeAfterToggle))
    }
    
    func testSetShuffleMode() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            for newShuffleMode in ShuffleMode.allCases {
                
                // When the new repeat mode is .one, the new shuffle mode must be .off because
                // repeat one and shuffle on cannot be set simultaneously; they are mutually exclusive
                doTestSetShuffleMode(repeatMode, shuffleMode, (repeatMode, newShuffleMode) == (.one, .on) ? .off : repeatMode, newShuffleMode)
            }
        }
    }
    
    private func doTestSetShuffleMode(_ repeatModeBefore: RepeatMode, _ shuffleModeBefore: ShuffleMode,
                                     _ expectedRepeatModeAfter: RepeatMode, _ newShuffleMode: ShuffleMode) {
        
        _ = sequencer.setRepeatMode(repeatModeBefore)
        let modes = sequencer.setShuffleMode(shuffleModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequencer.setShuffleMode(newShuffleMode)
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfter, newShuffleMode))
    }
    
    // MARK: repeatAndShuffleModes() tests
    
    func testRepeatAndShuffleModes_validModes() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            _ = sequencer.setRepeatMode(repeatMode)
            _ = sequencer.setShuffleMode(shuffleMode)

            let modes = sequencer.repeatAndShuffleModes

            XCTAssertEqual(modes.repeatMode, repeatMode)
            XCTAssertEqual(modes.shuffleMode, shuffleMode)
        }
    }
    
    func testRepeatAndShuffleModes_invalidModes() {
        
        // Set repeat one, then shuffle on
        _ = sequencer.setRepeatMode(.one)
        _ = sequencer.setShuffleMode(.on)
        
        var modes = sequencer.repeatAndShuffleModes

        // Repeat should have been disabled
        XCTAssertEqual(modes.repeatMode, .off)
        XCTAssertEqual(modes.shuffleMode, .on)
        
        // Set shuffle on, then repeat one
        _ = sequencer.setShuffleMode(.on)
        _ = sequencer.setRepeatMode(.one)
        
        modes = sequencer.repeatAndShuffleModes

        // Shuffle should have been disabled
        XCTAssertEqual(modes.repeatMode, .one)
        XCTAssertEqual(modes.shuffleMode, .off)
    }
}
