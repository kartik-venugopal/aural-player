//
//  PlaybackSequenceRepeatAndShuffleTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackSequenceRepeatAndShuffleTests: PlaybackSequenceTests {

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
        
        _ = sequence.setShuffleMode(shuffleModeBeforeToggle)
        let modes = sequence.setRepeatMode(repeatModeBeforeToggle)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBeforeToggle)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBeforeToggle)
        
        let modesAfterToggle = sequence.toggleRepeatMode()
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfterToggle, expectedShuffleModeAfterToggle))
        
        if modesAfterToggle == (.one, .off) {
            
            // When repeat one is set, shuffle is disabled, resulting in the shuffle sequence being cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
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
        
        _ = sequence.setShuffleMode(shuffleModeBefore)
        let modes = sequence.setRepeatMode(repeatModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequence.setRepeatMode(newRepeatMode)
        XCTAssertTrue(modesAfterToggle == (newRepeatMode, expectedShuffleModeAfter))
        
        if modesAfterToggle == (.one, .off) {
            
            // When repeat one is set, shuffle is disabled, resulting in the shuffle sequence being cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
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
        
        _ = sequence.setRepeatMode(repeatModeBeforeToggle)
        let modes = sequence.setShuffleMode(shuffleModeBeforeToggle)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBeforeToggle)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBeforeToggle)
        
        let modesAfterToggle = sequence.toggleShuffleMode()
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfterToggle, expectedShuffleModeAfterToggle))
        
        if modesAfterToggle.shuffleMode == .off {
            
            // When shuffle is disabled, the shuffle sequence should be cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
    }
    
    func testToggleShuffleMode_OffToOn_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Since no track is playing, shuffle sequence should not have been created when shuffle was set to On.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
    }
    
    func testToggleShuffleMode_OnToOff_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is on, but there is no playing track, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // On -> Off
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been cleared when shuffle was turned off.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    func testToggleShuffleMode_OffToOn_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
    }
    
    func testToggleShuffleMode_OnToOff_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is on, and there is a playing track, so shuffle sequence should not be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
        
        // On -> Off
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
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
        
        _ = sequence.setRepeatMode(repeatModeBefore)
        let modes = sequence.setShuffleMode(shuffleModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequence.setShuffleMode(newShuffleMode)
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfter, newShuffleMode))
    }
    
    func testSetShuffleMode_OffToOn_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Since no track is playing, shuffle sequence should not have been created when shuffle was set to On.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
    }
    
    func testSetShuffleMode_OnToOff_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is on, but there is no playing track, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // On -> Off
        let shuffleModeAfter = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been cleared when shuffle was turned off.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    func testSetShuffleMode_OffToOn_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
    }
    
    func testSetShuffleMode_OnToOff_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is on, and there is a playing track, so shuffle sequence should not be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
        
        // On -> Off
        let shuffleModeAfter = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    // MARK: repeatAndShuffleModes() tests
    
    func testRepeatAndShuffleModes_validModes() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            _ = sequence.setRepeatMode(repeatMode)
            _ = sequence.setShuffleMode(shuffleMode)

            let modes = sequence.repeatAndShuffleModes

            XCTAssertEqual(modes.repeatMode, repeatMode)
            XCTAssertEqual(modes.shuffleMode, shuffleMode)
        }
    }
    
    func testRepeatAndShuffleModes_invalidModes() {
        
        // Set repeat one, then shuffle on
        _ = sequence.setRepeatMode(.one)
        _ = sequence.setShuffleMode(.on)
        
        var modes = sequence.repeatAndShuffleModes

        // Repeat should have been disabled
        XCTAssertEqual(modes.repeatMode, .off)
        XCTAssertEqual(modes.shuffleMode, .on)
        
        // Set shuffle on, then repeat one
        _ = sequence.setShuffleMode(.on)
        _ = sequence.setRepeatMode(.one)
        
        modes = sequence.repeatAndShuffleModes

        // Shuffle should have been disabled
        XCTAssertEqual(modes.repeatMode, .one)
        XCTAssertEqual(modes.shuffleMode, .off)
    }
}
