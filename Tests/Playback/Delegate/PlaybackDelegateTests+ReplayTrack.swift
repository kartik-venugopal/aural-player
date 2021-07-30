//
//  PlaybackDelegateTests_ReplayTrack.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_ReplayTrack: PlaybackDelegateTestCase {

    func testReplay_noPlayingTrack() {

        delegate.replay()

        assertNoTrack()
        XCTAssertFalse(mockScheduler.seekToTimeInvoked)
    }

    func testReplay_trackPlaying() {

        let track = createTrack(title: "Like a Virgin", duration: 249.99887766)
        doBeginPlayback(track)

        delegate.replay()

        assertPlayingTrack(track)
        XCTAssertTrue(mockScheduler.seekToTimeInvoked)
        XCTAssertEqual(mockScheduler.seekToTime_time, 0)
    }

    func testReplay_trackPaused_resumesPlayback() {
        
        let track = createTrack(title: "Like a Virgin", duration: 249.99887766)
        doBeginPlayback(track)
        doPausePlayback(track)

        delegate.replay()

        assertPlayingTrack(track)
        XCTAssertTrue(mockScheduler.seekToTimeInvoked)
        XCTAssertEqual(mockScheduler.seekToTime_time, 0)
        XCTAssertTrue(mockScheduler.resumed)
    }
}
