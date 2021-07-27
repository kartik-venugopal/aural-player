//
//  LoopTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class LoopTests: PlaybackDelegateTests {
    
    func testToggleLoop_noTrackPlaying() {
        
        assertNoTrack()
        
        XCTAssertNil(delegate.toggleLoop())
        XCTAssertNil(delegate.playbackLoop)
        XCTAssertEqual(player.toggleLoopCallCount, 0)
        
        assertNoTrack()
    }

    func testToggleLoop_trackPlaying_noLoopDefined_loopStarted() {
        
        let track = createTrack(title: "Time", duration: 420)
        doBeginPlayback(track)
        XCTAssertNil(delegate.playbackLoop)
        
        let loop = delegate.toggleLoop()
        
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertFalse(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 1)
        
        assertPlayingTrack(track)
    }
    
    func testToggleLoop_trackPlaying_incompleteLoopDefined_loopCompleted() {
        
        let track = createTrack(title: "Time", duration: 420)
        doBeginPlayback(track)
        XCTAssertNil(delegate.playbackLoop)
        
        // Define the loop start time
        mockPlayerNode._seekPosition = 25.972349665
        var loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertFalse(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 1)
        
        assertPlayingTrack(track)

        // Define the loop end time
        mockPlayerNode._seekPosition = 37.1423432
        loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertTrue(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 2)
        
        assertPlayingTrack(track)
    }
    
    func testToggleLoop_trackPlaying_completeLoopDefined_loopRemoved() {
        
        let track = createTrack(title: "Time", duration: 420)
        doBeginPlayback(track)
        XCTAssertNil(delegate.playbackLoop)
        
        // Define the loop start time
        mockPlayerNode._seekPosition = 25.972349665
        var loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertFalse(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 1)
        
        assertPlayingTrack(track)

        // Define the loop end time
        mockPlayerNode._seekPosition = 37.1423432
        loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertTrue(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 2)
        
        assertPlayingTrack(track)
        
        // Remove the loop
        loop = delegate.toggleLoop()
        XCTAssertNil(loop)
        XCTAssertNil(delegate.playbackLoop)
        XCTAssertNil(player.toggleLoopResult)
        XCTAssertEqual(player.toggleLoopCallCount, 3)
        
        assertPlayingTrack(track)
    }
    
    func testToggleLoop_trackPaused_noLoopDefined_loopStarted() {
        
        let track = createTrack(title: "Time", duration: 420)
        doBeginPlayback(track)
        XCTAssertNil(delegate.playbackLoop)
        
        doPausePlayback(delegate.playingTrack!)
        
        let loop = delegate.toggleLoop()
        
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertFalse(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 1)
        
        assertPausedTrack(track)
    }
    
    func testToggleLoop_trackPaused_incompleteLoopDefined_loopCompleted() {
        
        let track = createTrack(title: "Time", duration: 420)
        doBeginPlayback(track)
        XCTAssertNil(delegate.playbackLoop)
        
        doPausePlayback(delegate.playingTrack!)
        
        // Define the loop start time
        mockPlayerNode._seekPosition = 25.972349665
        var loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertFalse(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 1)
        
        assertPausedTrack(track)

        // Define the loop end time
        mockPlayerNode._seekPosition = 37.1423432
        loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertTrue(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 2)
        
        assertPausedTrack(track)
    }
    
    func testToggleLoop_trackPaused_completeLoopDefined_loopRemoved() {
        
        let track = createTrack(title: "Time", duration: 420)
        doBeginPlayback(track)
        XCTAssertNil(delegate.playbackLoop)
        
        doPausePlayback(delegate.playingTrack!)
        
        // Define the loop start time
        mockPlayerNode._seekPosition = 25.972349665
        var loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertFalse(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 1)
        
        assertPausedTrack(track)

        // Define the loop end time
        mockPlayerNode._seekPosition = 37.1423432
        loop = delegate.toggleLoop()
        XCTAssertEqual(loop!, delegate.playbackLoop!)
        XCTAssertEqual(loop, player.toggleLoopResult!)
        XCTAssertTrue(loop!.isComplete)
        XCTAssertEqual(player.toggleLoopCallCount, 2)
        
        assertPausedTrack(track)
        
        // Remove the loop
        loop = delegate.toggleLoop()
        XCTAssertNil(loop)
        XCTAssertNil(delegate.playbackLoop)
        XCTAssertNil(player.toggleLoopResult)
        XCTAssertEqual(player.toggleLoopCallCount, 3)
        
        assertPausedTrack(track)
    }
}
