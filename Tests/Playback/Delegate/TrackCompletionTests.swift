//
//  TrackCompletionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class TrackCompletionTests: PlaybackDelegateTests {

    func testTrackPlaybackCompleted_noSubsequentTrack() {

        let completedTrack = createTrack(title: "So Far Away", duration: 300)
        doTestTrackPlaybackCompleted(completedTrack, nil)
    }

    func testTrackPlaybackCompleted_hasSubsequentTrack() {

        let completedTrack = createTrack(title: "So Far Away", duration: 300)
        let subsequentTrack = createTrack(title: "Private Investigations", duration: 360)

        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack)
    }

    private func doTestTrackPlaybackCompleted(_ completedTrack: Track, _ subsequentTrack: Track?) {

        doBeginPlayback(completedTrack)
        sequencer.subsequentTrack = subsequentTrack

        delegate.trackPlaybackCompleted(PlaybackSession.currentSession!)

        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)

        if let theSubsequentTrack = subsequentTrack {

            assertPlayingTrack(theSubsequentTrack)

            XCTAssertEqual(startPlaybackChain.executionCount, 2)
            XCTAssertTrue(trackPlaybackCompletedChain.executedContext! === startPlaybackChain.executedContext!)

        } else {

            assertNoTrack()
            XCTAssertEqual(startPlaybackChain.executionCount, 1)
            XCTAssertEqual(stopPlaybackChain.executionCount, 1)
            XCTAssertTrue(trackPlaybackCompletedChain.executedContext! === stopPlaybackChain.executedContext!)
        }
    }
}
