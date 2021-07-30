//
//  PlaybackDelegateTests+TrackIteration.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_TrackIteration: PlaybackDelegateTestCase {

    // MARK: previousTrack() tests ------------------------------------------------------------------------------------------

    // When no track is playing, previous() does nothing.
    func testPreviousTrack_noTrackPlaying() {

        sequencer.previousTrack = createTrack(title: "PreviousTrack", duration: 100)
        delegate.previousTrack()
        assertNoTrack()

        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.previousCallCount, 0)

        XCTAssertEqual(self.trackTransitionMessages.count, 0)
    }

    func testPreviousTrack_trackPlaying_noPreviousTrack() {

        doBeginPlayback(createTrack(title: "FirstTrack", duration: 300))
        doPreviousTrack(nil)
    }

    func testPreviousTrack_trackPaused_noPreviousTrack() {

        let someTrack = createTrack(title: "FirstTrack", duration: 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)

        doPreviousTrack(nil)
    }

    func testPreviousTrack_trackPlaying_trackChanges() {

        doBeginPlayback(createTrack(title: "SomeTrack", duration: 300))
        doPreviousTrack(createTrack(title: "PreviousTrack", duration: 400))
    }

    func testPreviousTrack_trackPaused_trackChanges() {

        let someTrack = createTrack(title: "SomeTrack", duration: 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)

        doPreviousTrack(createTrack(title: "PreviousTrack", duration: 400))
    }

    private func doPreviousTrack(_ track: Track?) {

        let trackBeforeChange = delegate.playingTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed

        let previousCallCountBeforeChange = sequencer.previousCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount

        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count

        sequencer.previousTrack = track
        delegate.previousTrack()

        if track != nil {

            assertPlayingTrack(track!)

            verifyRequestContext_startPlaybackChain(stateBeforeChange, trackBeforeChange,
            seekPosBeforeChange, track!, PlaybackParams.defaultParams(), true)

        } else {

            // When there is no previous track to play, the track and state from before the previous() call should remain unchanged.

            switch stateBeforeChange {

            case .noTrack:

                assertNoTrack()

            case .playing:

                assertPlayingTrack(trackBeforeChange!)

            case .paused:

                assertPausedTrack(trackBeforeChange!)
            }
        }

        XCTAssertEqual(sequencer.previousCallCount, previousCallCountBeforeChange + 1)
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + (track != nil ? 1 : 0))

        if track != nil {
            self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackTransitionMsgCountBeforeChange + 1)
        } else {
            XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        }
    }

    // MARK: nextTrack() tests ------------------------------------------------------------------------------------------

    // When no track is playing, next() does nothing.
    func testNextTrack_noTrackPlaying() {

        delegate.nextTrack()
        assertNoTrack()

        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.nextCallCount, 0)

        XCTAssertEqual(self.trackTransitionMessages.count, 0)
    }

    func testNextTrack_trackPlaying_noNextTrack() {

        doBeginPlayback(createTrack(title: "FirstTrack", duration: 300))
        doNextTrack(nil)
    }

    func testNextTrack_trackPaused_noNextTrack() {

        let someTrack = createTrack(title: "FirstTrack", duration: 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)

        doNextTrack(nil)
    }

    func testNextTrack_trackPlaying_trackChanges() {

        doBeginPlayback(createTrack(title: "SomeTrack", duration: 300))
        doNextTrack(createTrack(title: "NextTrack", duration: 400))
    }

    func testNextTrack_trackPaused_trackChanges() {

        let someTrack = createTrack(title: "SomeTrack", duration: 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)

        doNextTrack(createTrack(title: "NextTrack", duration: 400))
    }

    private func doNextTrack(_ track: Track?) {

        let trackBeforeChange = delegate.playingTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed

        let nextCallCountBeforeChange = sequencer.nextCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount

        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count

        sequencer.nextTrack = track
        delegate.nextTrack()

        if track != nil {

            assertPlayingTrack(track!)

            verifyRequestContext_startPlaybackChain(stateBeforeChange, trackBeforeChange,
            seekPosBeforeChange, track!, PlaybackParams.defaultParams(), true)

        } else {

            // When there is no next track to play, the track and state from before the next() call should remain unchanged.

            switch stateBeforeChange {

            case .noTrack:

                assertNoTrack()
                
            case .playing:

                assertPlayingTrack(trackBeforeChange!)

            case .paused:

                assertPausedTrack(trackBeforeChange!)
            }
        }

        XCTAssertEqual(sequencer.nextCallCount, nextCallCountBeforeChange + 1)
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + (track != nil ? 1 : 0))

        if track != nil {
            self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackTransitionMsgCountBeforeChange + 1)
        } else {
            XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        }
    }
}
