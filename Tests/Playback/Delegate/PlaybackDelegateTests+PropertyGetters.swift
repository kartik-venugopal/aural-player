//
//  PlaybackDelegateTests+PropertyGetters.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_PropertyGetters: PlaybackDelegateTestCase {

    // MARK: state tests -------------------------------------------------------------------------------------

    func testPlaybackState_noTrack() {

        delegate.stop()
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
    }

    func testPlaybackState_playing() {

        delegate.play(createTrack(title: "So Far Away", duration: 300))
        XCTAssertEqual(delegate.state, PlaybackState.playing)
    }

    func testPlaybackState_paused() {

        delegate.play(createTrack(title: "So Far Away", duration: 300))
        XCTAssertEqual(delegate.state, PlaybackState.playing)

        delegate.togglePlayPause()
        XCTAssertEqual(delegate.state, PlaybackState.paused)
    }

    func testPlaybackState_pausedAndResumed() {

        delegate.play(createTrack(title: "So Far Away", duration: 300))
        XCTAssertEqual(delegate.state, PlaybackState.playing)

        delegate.togglePlayPause()
        XCTAssertEqual(delegate.state, PlaybackState.paused)

        delegate.togglePlayPause()
        XCTAssertEqual(delegate.state, PlaybackState.playing)
    }

    // MARK: seekPosition tests -------------------------------------------------------------------------------------

    func testSeekPosition_noTrackPlaying() {

        delegate.stop()
        assertNoTrack()

        let delegateSeekPosition = delegate.seekPosition

        XCTAssertEqual(delegateSeekPosition.timeElapsed, 0, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.percentageElapsed, 0, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.trackDuration, 0, accuracy: 0.001)
    }

    func testSeekPosition_trackPlaying() {

        var trackDurations: Set<Double> = Set([1, 5, 30, 60, 180, 300, 600, 1800, 3600, 36000, 360000])
        for _ in 1...1000 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "So Far Away", duration: trackDuration)
            delegate.play(track)
            XCTAssertEqual(delegate.playingTrack!, track)

            var seekPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...1000 {
                seekPositions.insert(Double.random(in: 0...trackDuration))
            }

            for seekPosition in seekPositions {
                doTestSeekPosition(track, seekPosition)
            }
        }
    }

    func testSeekPosition_trackPaused() {

        var trackDurations: Set<Double> = Set([1, 5, 30, 60, 180, 300, 600, 1800, 3600, 36000, 360000])
        for _ in 1...1000 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "So Far Away", duration: trackDuration)
            delegate.play(track)
            delegate.togglePlayPause()

            XCTAssertEqual(delegate.state, PlaybackState.paused)
            XCTAssertEqual(delegate.playingTrack!, track)

            var seekPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...1000 {
                seekPositions.insert(Double.random(in: 0...trackDuration))
            }

            for seekPosition in seekPositions {
                doTestSeekPosition(track, seekPosition)
            }
        }
    }

    private func doTestSeekPosition(_ track: Track, _ seekPos: Double) {

        mockPlayerNode._seekPosition = seekPos

        let delegateSeekPosition = delegate.seekPosition

        XCTAssertEqual(delegateSeekPosition.timeElapsed, seekPos, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.percentageElapsed, seekPos * 100 / track.duration, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.trackDuration, track.duration, accuracy: 0.001)
    }

    // MARK: playingTrack tests -------------------------------------------------------------------------------------

    func testPlayingTrack_noTrack() {

        delegate.stop()
        XCTAssertNil(delegate.playingTrack)
    }

    func testPlayingTrack_playing() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)

        XCTAssertEqual(delegate.playingTrack!, track)
    }

    func testPlayingTrack_paused() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        delegate.togglePlayPause()
        XCTAssertEqual(delegate.playingTrack!, track)
    }

    // MARK: playingTrackStartTime tests -------------------------------------------------------------------------------------

    func testPlayingTrackStartTime_noCurrentSession() {

        // No playback session exists
        XCTAssertFalse(PlaybackSession.hasCurrentSession())
        XCTAssertNil(PlaybackSession.currentSession)

        // Verify that the delegate's playingTrackStartTime property returns nil
        XCTAssertNil(delegate.playingTrackStartTime)
    }

    func testPlayingTrackStartTime_hasCurrentSession() {

        // Start a new playback session
        _ = PlaybackSession.start(createTrack(title: "So Far Away", duration: 300))
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        XCTAssertNotNil(PlaybackSession.currentSession?.timestamp)

        // Verify that the delegate's playingTrackStartTime property matches the timestamp of the new playback session
        XCTAssertEqual(delegate.playingTrackStartTime!, PlaybackSession.currentSession!.timestamp, accuracy: 0.001)
    }
}
