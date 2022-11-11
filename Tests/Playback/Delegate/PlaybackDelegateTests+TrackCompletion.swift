//
//  PlaybackDelegateTests+TrackCompletion.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_TrackCompletion: PlaybackDelegateTestCase {

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
    
    // ----------------------------------------------------------------------------
    
    // MARK: End-to-end tests
    
    func testEndToEnd_noSubsequentTrack() {

        let track = createTrack(title: "Money for Nothing", duration: 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())

        sequencer.subsequentTrack = nil

        // Publish a message for the delegate to process
        messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)

        executeAfter(0.2) {

            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 1)
            XCTAssertEqual(self.stopPlaybackChain.executionCount, 1)

            self.assertNoTrack()
        }
    }

    func testEndToEnd_hasSubsequentTrack() {

        let track = createTrack(title: "Money for Nothing", duration: 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())

        let subsequentTrack = createTrack(title: "Private Investigations", duration: 360)
        sequencer.subsequentTrack = subsequentTrack

        // Publish a message for the delegate to process
        messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)

        executeAfter(0.2) {

            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)

            self.assertPlayingTrack(subsequentTrack)
        }
    }
}
