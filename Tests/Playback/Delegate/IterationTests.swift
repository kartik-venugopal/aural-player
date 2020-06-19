import XCTest

class IterationTests: PlaybackDelegateTests {
    
    // MARK: previousTrack() tests ------------------------------------------------------------------------------------------
    
    // When no track is playing, previous() does nothing.
    func testPreviousTrack_noTrackPlaying() {

        sequencer.previousTrack = createTrack("PreviousTrack", 100)
        delegate.previousTrack()
        assertNoTrack()
        
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.previousCallCount, 0)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
    }
    
    func testPreviousTrack_trackPlaying_noPreviousTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPreviousTrack(nil)
    }
    
    func testPreviousTrack_trackPaused_noPreviousTrack() {
        
        let someTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        doPreviousTrack(nil)
    }
    
    func testPreviousTrack_trackPlaying_trackChanges() {
        
        doBeginPlayback(createTrack("SomeTrack", 300))
        doPreviousTrack(createTrack("PreviousTrack", 400))
    }
    
    func testPreviousTrack_trackPaused_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        doPreviousTrack(createTrack("PreviousTrack", 400))
    }
    
    func testPreviousTrack_trackWaiting_noPreviousTrack() {
        
        doBeginPlaybackWithDelay(createTrack("SomeTrack", 300), 5)
        doPreviousTrack(nil)
        
        XCTAssertEqual(startPlaybackChain.executedContext!.delay, 5)
    }
    
    func testPreviousTrack_trackWaiting_trackChanges() {
        
        doBeginPlaybackWithDelay(createTrack("SomeTrack", 300), 5)
        doPreviousTrack(createTrack("PreviousTrack", 400))
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPreviousTrack_trackTranscoding_noPreviousTrack() {
        
        doBeginPlayback_trackNeedsTranscoding(createTrack("SomeTrack", "ape", 300))
        doPreviousTrack(nil)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 0)
        XCTAssertEqual(transcoder.transcodeCancel_track, nil)
    }
    
    func testPreviousTrack_trackTranscoding_trackChanges() {
        
        let track = createTrack("SomeTrack", "ape", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        doPreviousTrack(createTrack("PreviousTrack", 400))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPreviousTrack_trackPlaying_gapBeforePreviousTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        
        let previousTrack: Track = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        
        // Set a gap before previous track (in the playlist)
        playlist.setGapsForTrack(previousTrack, PlaybackGap(5, .beforeTrack, .oneTime), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(previousTrack))
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.previousTrack()
        
        // Track should have changed (and should be in waiting state)
        assertWaitingTrack(previousTrack, 5)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.waiting, previousTrack,
                                                seekPosBeforeChange, previousTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
        self.assertGapStarted(someTrack, previousTrack)
    }
    
    func testPreviousTrack_trackPlaying_previousTrackNeedsTranscoding() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        
        let previousTrack = createTrack("PreviousTrack", "wma", 400)
        sequencer.previousTrack = previousTrack
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.previousTrack()
        
        // Track should have changed (and should now be in transcoding state)
        assertTranscodingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.transcoding, previousTrack,
        seekPosBeforeChange, previousTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.previousCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, previousTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testPreviousTrack_trackPaused_gapBeforePreviousTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        let previousTrack: Track = createTrack("PreviousTrack", 400)
        sequencer.previousTrack = previousTrack
        
        // Set a gap before previous track (in the playlist)
        playlist.setGapsForTrack(previousTrack, PlaybackGap(5, .beforeTrack, .oneTime), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(previousTrack))
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.previousTrack()
        
        // Track should have changed (and should be in waiting state)
        assertWaitingTrack(previousTrack, 5)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.waiting, previousTrack,
                                                seekPosBeforeChange, previousTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
        self.assertGapStarted(someTrack, previousTrack)
    }
    
    func testPreviousTrack_trackPaused_previousTrackNeedsTranscoding() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        let previousTrack = createTrack("PreviousTrack", "wma", 400)
        sequencer.previousTrack = previousTrack
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.previousTrack()
        
        // Track should have changed (and should now be in transcoding state)
        assertTranscodingTrack(previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.transcoding, previousTrack,
        seekPosBeforeChange, previousTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.previousCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, previousTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    private func doPreviousTrack(_ track: Track?) {
        
        let trackBeforeChange = delegate.currentTrack
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
                
            case .waiting:
                
                assertWaitingTrack(trackBeforeChange!)
                
            case .transcoding:
                
                assertTranscodingTrack(trackBeforeChange!)
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
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doNextTrack(nil)
    }
    
    func testNextTrack_trackPaused_noNextTrack() {
        
        let someTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        doNextTrack(nil)
    }
    
    func testNextTrack_trackPlaying_trackChanges() {
        
        doBeginPlayback(createTrack("SomeTrack", 300))
        doNextTrack(createTrack("NextTrack", 400))
    }
    
    func testNextTrack_trackPaused_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        doNextTrack(createTrack("NextTrack", 400))
    }
    
    func testNextTrack_trackWaiting_noNextTrack() {
        
        doBeginPlaybackWithDelay(createTrack("SomeTrack", 300), 5)
        doNextTrack(nil)
        
        XCTAssertEqual(startPlaybackChain.executedContext!.delay, 5)
    }
    
    func testNextTrack_trackWaiting_trackChanges() {
        
        doBeginPlaybackWithDelay(createTrack("SomeTrack", 300), 5)
        doNextTrack(createTrack("NextTrack", 400))
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testNextTrack_trackTranscoding_noNextTrack() {
        
        doBeginPlayback_trackNeedsTranscoding(createTrack("SomeTrack", "ape", 300))
        doNextTrack(nil)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 0)
        XCTAssertEqual(transcoder.transcodeCancel_track, nil)
    }
    
    func testNextTrack_trackTranscoding_trackChanges() {
        
        let track = createTrack("SomeTrack", "ape", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        doNextTrack(createTrack("NextTrack", 400))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testNextTrack_trackPlaying_gapBeforeNextTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        
        let nextTrack: Track = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        
        // Set a gap before next track (in the playlist)
        playlist.setGapsForTrack(nextTrack, PlaybackGap(5, .beforeTrack, .oneTime), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(nextTrack))
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.nextTrack()
        
        // Track should have changed (and should be in waiting state)
        assertWaitingTrack(nextTrack, 5)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.waiting, nextTrack,
        seekPosBeforeChange, nextTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
        self.assertGapStarted(someTrack, nextTrack)
    }
    
    func testNextTrack_trackPlaying_nextTrackNeedsTranscoding() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        
        let nextTrack = createTrack("NextTrack", "wma", 400)
        sequencer.nextTrack = nextTrack
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.nextTrack()
        
        // Track should have changed (and should now be in transcoding state)
        assertTranscodingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.transcoding, nextTrack,
        seekPosBeforeChange, nextTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.nextCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, nextTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testNextTrack_trackPaused_gapBeforeNextTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        let nextTrack: Track = createTrack("NextTrack", 400)
        sequencer.nextTrack = nextTrack
        
        // Set a gap before next track (in the playlist)
        playlist.setGapsForTrack(nextTrack, PlaybackGap(5, .beforeTrack, .oneTime), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(nextTrack))
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.nextTrack()
        
        // Track should have changed (and should be in waiting state)
        assertWaitingTrack(nextTrack, 5)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.waiting, nextTrack,
        seekPosBeforeChange, nextTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
        self.assertGapStarted(someTrack, nextTrack)
    }
    
    func testNextTrack_trackPaused_nextTrackNeedsTranscoding() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        doPausePlayback(someTrack)
        
        let nextTrack = createTrack("NextTrack", "wma", 400)
        sequencer.nextTrack = nextTrack
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.nextTrack()
        
        // Track should have changed (and should now be in transcoding state)
        assertTranscodingTrack(nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        verifyRequestContext_startPlaybackChain(.transcoding, nextTrack,
        seekPosBeforeChange, nextTrack, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.nextCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, nextTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    private func doNextTrack(_ track: Track?) {
        
        let trackBeforeChange = delegate.currentTrack
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
                
            case .waiting:
                
                assertWaitingTrack(trackBeforeChange!)
                
            case .transcoding:
                
                assertTranscodingTrack(trackBeforeChange!)
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
