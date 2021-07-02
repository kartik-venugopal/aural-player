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

//class TrackCompletion_EndToEndTests: PlaybackDelegateTests {
//
//    // TODO: Add more cases from TrackCompletionTests
//
//    // MARK: Track completion tests -----------------------------------------------------------------------------
//
//    func testTrackCompletion_noSubsequentTrack() {
//
//        let track = createTrack("Money for Nothing", 420)
//        doBeginPlayback(track)
//        XCTAssertTrue(PlaybackSession.hasCurrentSession())
//
//        sequencer.subsequentTrack = nil
//
//        // Publish a message for the delegate to process
//        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
//
//        executeAfter(0.2) {
//
//            // Message should have been processed ... track playback should have continued
//            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
//            XCTAssertEqual(self.startPlaybackChain.executionCount, 1)
//            XCTAssertEqual(self.stopPlaybackChain.executionCount, 1)
//
//            self.assertNoTrack()
//        }
//    }
//
//    func testTrackCompletion_noDelay() {
//
//        let track = createTrack("Money for Nothing", 420)
//        doBeginPlayback(track)
//        XCTAssertTrue(PlaybackSession.hasCurrentSession())
//
//        let subsequentTrack = createTrack("Private Investigations", 360)
//        sequencer.subsequentTrack = subsequentTrack
//
//        preferences.gapBetweenTracks = false
//
//        // Publish a message for the delegate to process
//        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
//
//        executeAfter(0.2) {
//
//            // Message should have been processed ... track playback should have continued
//            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
//            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
//
//            self.assertPlayingTrack(subsequentTrack)
//        }
//    }
//
//    //    func testTrackPlaybackCompleted_noSubsequentTrack_gapAfterCompletedTrack() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_noSubsequentTrack_gapBetweenTracks() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_noDelay_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBetweenTracks() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBetweenTracks_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_gapBetweenTracks() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_gapBetweenTracks_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_gapBetweenTracks() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_gapBetweenTracks_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_trackNeedsTranscoding() {
//    //    }
//    //
//    //    func testTrackPlaybackCompleted_gapBetweenTracks_trackNeedsTranscoding() {
//    //    }
//}
