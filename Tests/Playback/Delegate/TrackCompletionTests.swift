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

//class TrackCompletionTests: PlaybackDelegateTests {
//
//    func testTrackPlaybackCompleted_noSubsequentTrack() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        doTestTrackPlaybackCompleted(completedTrack, nil, nil)
//    }
//
//    func testTrackPlaybackCompleted_noSubsequentTrack_gapAfterCompletedTrack() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        doTestTrackPlaybackCompleted(completedTrack, nil, nil, 5)
//    }
//
//    func testTrackPlaybackCompleted_noSubsequentTrack_gapBetweenTracks() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        doTestTrackPlaybackCompleted(completedTrack, nil, nil, nil, nil, 5)
//    }
//
//    func testTrackPlaybackCompleted_noDelay() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, nil)
//    }
//
//    func testTrackPlaybackCompleted_noDelay_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, nil)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 5, 5)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 5, 5)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBetweenTracks() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 5, 5, nil, 8)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBetweenTracks_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 5, 5, nil, 8)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, (5 + 8), 5, 8, nil)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, (5 + 8), 5, 8, nil)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_gapBetweenTracks() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, (5 + 8), 5, 8, 10)
//    }
//
//    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_gapBetweenTracks_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, (5 + 8), 5, 8, 10)
//    }
//
//    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_gapBetweenTracks() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 8, nil, 8, 10)
//    }
//
//    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_gapBetweenTracks_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 8, nil, 8, 10)
//    }
//
//    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 8, nil, 8)
//    }
//
//    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 8, nil, 8)
//    }
//
//    func testTrackPlaybackCompleted_gapBetweenTracks() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 10, nil, nil, 10)
//    }
//
//    func testTrackPlaybackCompleted_gapBetweenTracks_trackNeedsTranscoding() {
//
//        let completedTrack = createTrack("So Far Away", 300)
//        let subsequentTrack = createTrack("Private Investigations", "ogg", 360)
//
//        doTestTrackPlaybackCompleted(completedTrack, subsequentTrack, 10, nil, nil, 10)
//    }
//
//    private func doTestTrackPlaybackCompleted(_ completedTrack: Track, _ subsequentTrack: Track?, _ expectedDelay: Double?, _ delayAfterCompletedTrack: Double? = nil, _ delayBeforeSubsequentTrack: Double? = nil, _ gapBetweenTracksPreference: Int? = nil) {
//
//        doBeginPlayback(completedTrack)
//        sequencer.subsequentTrack = subsequentTrack
//
//        let needsTranscoding: Bool = !(subsequentTrack?.playbackNativelySupported ?? true)
//
//        if let gapDuration = delayAfterCompletedTrack {
//
//            // Define a playlist gap after the completed track
//            let gapAfterCompletedTrack = PlaybackGap(gapDuration, .afterTrack)
//            playlist.setGapsForTrack(completedTrack, nil, gapAfterCompletedTrack)
//            XCTAssertEqual(playlist.getGapAfterTrack(completedTrack), gapAfterCompletedTrack)
//        }
//
//        if let theSubsequentTrack = subsequentTrack {
//
//            if let gapDuration = delayBeforeSubsequentTrack {
//
//                // Define a playlist gap after the completed track
//                let gapBeforeSubsequentTrack = PlaybackGap(gapDuration, .beforeTrack)
//                playlist.setGapsForTrack(theSubsequentTrack, gapBeforeSubsequentTrack, nil)
//                XCTAssertEqual(playlist.getGapBeforeTrack(theSubsequentTrack), gapBeforeSubsequentTrack)
//            }
//        }
//
//        // Define a gap between tracks (in the preferences)
//        if let gapDuration = gapBetweenTracksPreference {
//
//            preferences.gapBetweenTracks = true
//            preferences.gapBetweenTracksDuration = gapDuration
//
//        } else {
//
//            preferences.gapBetweenTracks = false
//        }
//
//        if needsTranscoding {
//            transcoder.transcodeImmediately_readyForPlayback = false
//            transcoder.transcodeImmediately_failed = false
//        }
//
//        delegate.trackPlaybackCompleted(PlaybackSession.currentSession!)
//
//        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
//
//        if let theSubsequentTrack = subsequentTrack {
//
//            if let theExpectedDelay = expectedDelay {
//                assertWaitingTrack(theSubsequentTrack, theExpectedDelay)
//
//            } else if needsTranscoding {
//                assertTranscodingTrack(theSubsequentTrack)
//
//            } else {
//                assertPlayingTrack(theSubsequentTrack)
//            }
//
//            XCTAssertEqual(startPlaybackChain.executionCount, 2)
//            XCTAssertTrue(trackPlaybackCompletedChain.executedContext! === startPlaybackChain.executedContext!)
//
//            if needsTranscoding {
//
//                XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
//                XCTAssertEqual(transcoder.transcodeImmediately_track, theSubsequentTrack)
//            }
//
//        } else {
//
//            assertNoTrack()
//            XCTAssertEqual(startPlaybackChain.executionCount, 1)
//            XCTAssertEqual(stopPlaybackChain.executionCount, 1)
//            XCTAssertTrue(trackPlaybackCompletedChain.executedContext! === stopPlaybackChain.executedContext!)
//        }
//    }
//}
