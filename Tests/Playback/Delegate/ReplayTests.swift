//
//  ReplayTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class ReplayTests: PlaybackDelegateTests {

    func testReplay_noPlayingTrack() {
        
        delegate.replay()

        assertNoTrack()
        XCTAssertFalse(mockScheduler.seekToTimeInvoked)
    }
    
    func testReplay_trackPlaying() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        delegate.replay()

        assertPlayingTrack(track)
        XCTAssertTrue(mockScheduler.seekToTimeInvoked)
        XCTAssertEqual(mockScheduler.seekToTime_time, 0)
    }
    
    func testReplay_trackPaused_resumesPlayback() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        doPausePlayback(track)
        
        delegate.replay()

        assertPlayingTrack(track)
        XCTAssertTrue(mockScheduler.seekToTimeInvoked)
        XCTAssertEqual(mockScheduler.seekToTime_time, 0)
        XCTAssertTrue(mockScheduler.resumed)
    }
    
    func testReplay_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.replay()

        // replay() should have had no effect.
        assertWaitingTrack(track, 5)
        XCTAssertFalse(mockScheduler.seekToTimeInvoked)
    }
    
    func testReplay_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "ogg", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.replay()

        // replay() should have had no effect.
        assertTranscodingTrack(track)
        XCTAssertFalse(mockScheduler.seekToTimeInvoked)
    }
}
