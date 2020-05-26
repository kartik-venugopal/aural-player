import XCTest

class PlaybackDelegate_IterationTests: PlaybackDelegateTests {
    
    // MARK: previousTrack() tests ------------------------------------------------------------------------------------------

    // When no track is playing, previous() does nothing.
    func testPrevious_noTrackPlaying() {

        delegate.previousTrack()
        
        XCTAssertNil(delegate.playingTrack)
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.previousCallCount, 0)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
        }
    }
    
    func testPrevious_trackPlaying_noPreviousTrack() {
        
        sequencer.beginTrack = createTrack("FirstTrack", 300)
    
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.delegate.playingTrack!)
        }
        
        sequencer.previousTrack = nil
        
        delegate.previousTrack()
        
        // Track should not have changed, because previous() returned nil.
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testPrevious_trackPaused_noPreviousTrack() {
        
        sequencer.beginTrack = createTrack("FirstTrack", 300)
    
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.beginCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.delegate.playingTrack!)
        }
        
        // Pause playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        sequencer.previousTrack = nil
        
        delegate.previousTrack()
        
        // Track and playback state should not have changed, because previous() returned nil.
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testPrevious_trackPlaying_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectedTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.delegate.playingTrack!)
        }
        
        sequencer.previousTrack = createTrack("PreviousTrack", 400)
        
        delegate.previousTrack()
        
        // Track should have changed
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.previousTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 2)
            
            let trackChangeMsg = self.trackChangeMessages[1]
            XCTAssertEqual(trackChangeMsg.oldTrack, self.sequencer.selectedTrack!)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.playing)
            XCTAssertEqual(trackChangeMsg.newTrack, self.delegate.playingTrack!)
        }
    }
    
    func testPrevious_trackPaused_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectedTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.selectedTrack!)
        }
        
        // Pause playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.playingTrack, sequencer.selectedTrack!)
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        sequencer.previousTrack = createTrack("PreviousTrack", 400)
        
        delegate.previousTrack()
        
        // Track should have changed
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.previousTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 2)
            
            let trackChangeMsg = self.trackChangeMessages[1]
            XCTAssertEqual(trackChangeMsg.oldTrack, someTrack)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.paused)
            XCTAssertEqual(trackChangeMsg.newTrack, self.delegate.playingTrack!)
        }
    }
    
    func testPrevious_trackWaiting_noPreviousTrack() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback with a delay
        delegate.play(someTrack, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
        XCTAssertEqual(delegate.waitingTrack, sequencer.selectedTrack!)
        XCTAssertNil(delegate.playingTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
            
            let gapStartedMsg = self.gapStartedMessages.first!
            XCTAssertEqual(gapStartedMsg.lastPlayedTrack, nil)
            XCTAssertEqual(gapStartedMsg.nextTrack, self.delegate.waitingTrack!)
            XCTAssertEqual(gapStartedMsg.gapEndTime.compare(Date()), ComparisonResult.orderedDescending)
        }
        
        // Play the previous track
        sequencer.previousTrack = nil
        delegate.previousTrack()
        
        // Track and playback state should not have changed
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
        XCTAssertEqual(delegate.waitingTrack!, someTrack)
        XCTAssertNil(delegate.playingTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
        }
    }
    
    func testPrevious_trackWaiting_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback with a delay
        delegate.play(someTrack, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
        XCTAssertEqual(delegate.waitingTrack, sequencer.selectedTrack!)
        XCTAssertNil(delegate.playingTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
            
            let gapStartedMsg = self.gapStartedMessages.first!
            XCTAssertEqual(gapStartedMsg.lastPlayedTrack, nil)
            XCTAssertEqual(gapStartedMsg.nextTrack, self.delegate.waitingTrack!)
            XCTAssertEqual(gapStartedMsg.gapEndTime.compare(Date()), ComparisonResult.orderedDescending)
        }
        
        // Play the previous track
        sequencer.previousTrack = createTrack("PreviousTrack", 400)
        delegate.previousTrack()
        
        // Track should have changed
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.previousTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.previousCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, someTrack)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.waiting)
            XCTAssertEqual(trackChangeMsg.newTrack, self.delegate.playingTrack!)
        }
    }
    
    // MARK: nextTrack() tests ------------------------------------------------------------------------------------------
    
    // When no track is playing, next() does nothing.
    func testNext_noTrackPlaying() {

        delegate.nextTrack()
        
        XCTAssertNil(delegate.playingTrack)
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(sequencer.nextCallCount, 0)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
        }
    }
    
    func testNext_trackPlaying_noNextTrack() {
        
        sequencer.beginTrack = createTrack("FirstTrack", 300)
    
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.beginTrack!)
        }
        
        sequencer.nextTrack = nil
        
        delegate.nextTrack()
        
        // Track should not have changed, because next() returned nil.
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testNext_trackPaused_noNextTrack() {
        
        sequencer.beginTrack = createTrack("FirstTrack", 300)
    
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.beginCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.beginTrack!)
        }
        
        // Pause playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        sequencer.nextTrack = nil
        
        delegate.nextTrack()
        
        // Track should not have changed, because next() returned nil.
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testNext_trackPlaying_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectedTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.selectedTrack!)
        }
        
        sequencer.nextTrack = createTrack("NextTrack", 400)
        
        delegate.nextTrack()
        
        // Track should have changed
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.nextTrack!)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 2)
            
            let trackChangeMsg = self.trackChangeMessages[1]
            XCTAssertEqual(trackChangeMsg.oldTrack, self.sequencer.selectedTrack!)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.playing)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.nextTrack!)
        }
    }
    
    func testNext_trackPaused_trackChanges() {
        
        let someTrack = createTrack("SomeTrack", 300)
        sequencer.selectedTrack = someTrack
    
        // Begin playback
        delegate.play(someTrack)
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectedTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.selectedTrack!)
        }
        
        // Pause playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.playingTrack, sequencer.selectedTrack!)
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        sequencer.nextTrack = createTrack("NextTrack", 400)
        
        delegate.nextTrack()
        
        // Track should have changed
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.nextTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(sequencer.nextCallCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 2)
        }
    }
}
