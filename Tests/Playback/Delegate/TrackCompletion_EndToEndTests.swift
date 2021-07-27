//
//  TrackCompletion_EndToEndTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class TrackCompletion_EndToEndTests: PlaybackDelegateTests {

    // MARK: Track completion tests -----------------------------------------------------------------------------

    func testTrackCompletion_noSubsequentTrack() {

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

    func testTrackCompletion_noDelay() {

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
