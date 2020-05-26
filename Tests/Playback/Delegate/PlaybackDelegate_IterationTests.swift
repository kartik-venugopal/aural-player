import XCTest

class PlaybackDelegate_IterationTests: PlaybackDelegateTests {
    
    // MARK: previousTrack() tests ------------------------------------------------------------------------------------------

    // When no track is playing, previous() does nothing.
    func testPreviousTrack_noTrackPlaying() {

        delegate.previousTrack()
        assertNoTrack()
        
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.previousCallCount, 0)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
        }
    }
    
    func testPreviousTrack_trackPlaying_noPreviousTrack() {
        
        let someTrack = createTrack("FirstTrack", 300)
        sequencer.beginTrack = someTrack
    
        // Begin playback
        delegate.togglePlayPause()
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        sequencer.previousTrack = nil
        delegate.previousTrack()
        
        // Track should not have changed, because previous() returned nil.
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testPreviousTrack_trackPaused_noPreviousTrack() {
        
        let someTrack = createTrack("FirstTrack", 300)
        sequencer.beginTrack = someTrack
    
        // Begin playback
        delegate.togglePlayPause()
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.beginCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        // Pause playback
        doPausePlayback(someTrack)
        
        sequencer.previousTrack = nil
        delegate.previousTrack()
        
        // Track and playback state should not have changed, because previous() returned nil.
        assertPausedTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testPreviousTrack_trackPlaying_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        let previousTrack = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        delegate.previousTrack()
        
        // Track should have changed
        assertPlayingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .playing, previousTrack, 2)
        }
    }
    
    func testPreviousTrack_trackPaused_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack, 1)
        }
        
        // Pause playback
        doPausePlayback(someTrack)
        
        let previousTrack = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        delegate.previousTrack()
        
        // Track should have changed
        assertPlayingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .paused, previousTrack, 2)
        }
    }
    
    func testPreviousTrack_trackWaiting_noPreviousTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback with a delay
        delegate.play(someTrack, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            self.assertGapStarted(nil, someTrack)
        }
        
        // Play the previous track
        sequencer.previousTrack = nil
        delegate.previousTrack()
        
        // Track and playback state should not have changed
        assertWaitingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
        }
    }
    
    func testPreviousTrack_trackWaiting_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback with a delay
        delegate.play(someTrack, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            self.assertGapStarted(nil, someTrack)
        }
        
        // Play the previous track
        let previousTrack = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        delegate.previousTrack()
        
        // Track should have changed
        assertPlayingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .waiting, previousTrack)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
        }
    }
    
    func testPreviousTrack_trackTranscoding_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", "ape", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertTranscodingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, someTrack)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 0)
        }
        
        // Play the previous track
        let previousTrack = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        delegate.previousTrack()
        
        // Track should have changed
        assertPlayingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .transcoding, previousTrack)
        }
    }
    
    func testPreviousTrack_gapBeforePreviousTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        let previousTrack: Track = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        
        // Set a gap before previous track (in the playlist)
        playlist.setGapsForTrack(previousTrack, PlaybackGap(5, .beforeTrack, .oneTime), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(previousTrack))
        
        delegate.previousTrack()
        
        // Track should have changed (and should be in waiting state)
        assertWaitingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            self.assertGapStarted(someTrack, previousTrack)
        }
    }
    
    func testPreviousTrack_previousTrackNeedsTranscoding() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        let previousTrack = createTrack("PreviousTrack", "wma", 400)
        sequencer.previousTrack = previousTrack
        
        delegate.previousTrack()
        
        // Track should have changed (and should now be in transcoding state)
        assertTranscodingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, previousTrack)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    // MARK: nextTrack() tests ------------------------------------------------------------------------------------------
    
    // When no track is playing, previous() does nothing.
    func testNextTrack_noTrackPlaying() {

        delegate.nextTrack()
        assertNoTrack()
        
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.nextCallCount, 0)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
        }
    }
    
    func testNextTrack_trackPlaying_noNextTrack() {
        
        let someTrack = createTrack("FirstTrack", 300)
        sequencer.beginTrack = someTrack
    
        // Begin playback
        delegate.togglePlayPause()
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        sequencer.nextTrack = nil
        delegate.nextTrack()
        
        // Track should not have changed, because next() returned nil.
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testNextTrack_trackPaused_noNextTrack() {
        
        let someTrack = createTrack("FirstTrack", 300)
        sequencer.beginTrack = someTrack
    
        // Begin playback
        delegate.togglePlayPause()
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.beginCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        // Pause playback
        doPausePlayback(someTrack)
        
        sequencer.nextTrack = nil
        delegate.nextTrack()
        
        // Track and playback state should not have changed, because next() returned nil.
        assertPausedTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testNextTrack_trackPlaying_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        let nextTrack = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        delegate.nextTrack()
        
        // Track should have changed
        assertPlayingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .playing, nextTrack, 2)
        }
    }
    
    func testNextTrack_trackPaused_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack, 1)
        }
        
        // Pause playback
        doPausePlayback(someTrack)
        
        let nextTrack = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        delegate.nextTrack()
        
        // Track should have changed
        assertPlayingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .paused, nextTrack, 2)
        }
    }
    
    func testNextTrack_trackWaiting_noNextTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback with a delay
        delegate.play(someTrack, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            self.assertGapStarted(nil, someTrack)
        }
        
        // Play the next track
        sequencer.nextTrack = nil
        delegate.nextTrack()
        
        // Track and playback state should not have changed
        assertWaitingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
        }
    }
    
    func testNextTrack_trackWaiting_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback with a delay
        delegate.play(someTrack, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            self.assertGapStarted(nil, someTrack)
        }
        
        // Play the next track
        let nextTrack = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        delegate.nextTrack()
        
        // Track should have changed
        assertPlayingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .waiting, nextTrack)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
        }
    }
    
    func testNextTrack_trackTranscoding_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", "ape", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertTranscodingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, someTrack)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 0)
        }
        
        // Play the next track
        let nextTrack = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        delegate.nextTrack()
        
        // Track should have changed
        assertPlayingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(someTrack, .transcoding, nextTrack)
        }
    }
    
    func testNextTrack_gapBeforeNextTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        let nextTrack: Track = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        
        // Set a gap before next track (in the playlist)
        playlist.setGapsForTrack(nextTrack, PlaybackGap(5, .beforeTrack, .oneTime), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(nextTrack))
        
        delegate.nextTrack()
        
        // Track should have changed (and should be in waiting state)
        assertWaitingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            self.assertGapStarted(someTrack, nextTrack)
        }
    }
    
    func testNextTrack_nextTrackNeedsTranscoding() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        assertPlayingTrack(someTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, someTrack)
        }
        
        let nextTrack = createTrack("NextTrack", "wma", 400)
        sequencer.nextTrack = nextTrack
        
        delegate.nextTrack()
        
        // Track should have changed (and should now be in transcoding state)
        assertTranscodingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, nextTrack)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
}
