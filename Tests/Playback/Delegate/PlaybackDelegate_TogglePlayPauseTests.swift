import XCTest

class PlaybackDelegate_TogglePlayPauseTests: PlaybackDelegateTests {

    func testTogglePlayPause_noTrackPlaying_emptyPlaylist() {
        
        sequencer.beginTrack = nil
        
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
        }
    }
    
    func testTogglePlayPause_noTrackPlaying_playbackBegins() {
        
        sequencer.beginTrack = createTrack("TestTrack", 300)
        
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.beginTrack!)
        }
    }
    
    func testTogglePlayPause_playing_pausesPlayback() {
        
        sequencer.beginTrack = createTrack("TestTrack", 300)
        
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.beginTrack!)
        }
        
        // Pause playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testTogglePlayPause_paused_resumesPlayback() {
        
        sequencer.beginTrack = createTrack("TestTrack", 300)
        
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, nil)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.noTrack)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.beginTrack!)
        }
        
        // Pause playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        // Resume playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.beginTrack)
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 1)
        }
    }
    
    func testTogglePlayPause_waiting_immediatePlayback() {
        
        let trackIndex: Int = 10
        sequencer.selectionTracksByIndex[trackIndex] = createTrack("TestTrack", 300)
        
        // Begin playback with a delay
        delegate.play(trackIndex, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertEqual(sequencer.selectIndexCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
        XCTAssertEqual(delegate.waitingTrack, sequencer.selectionTracksByIndex[trackIndex]!)
        XCTAssertNil(delegate.playingTrack)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 1)
            
            let gapStartedMsg = self.gapStartedMessages.first!
            XCTAssertEqual(gapStartedMsg.lastPlayedTrack, nil)
            XCTAssertEqual(gapStartedMsg.nextTrack, self.delegate.waitingTrack!)
            XCTAssertEqual(gapStartedMsg.gapEndTime.compare(Date()), ComparisonResult.orderedDescending)
        }
        
        // Cancel the delay and request immediate playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectionTracksByIndex[trackIndex])
        XCTAssertNil(delegate.waitingTrack)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMessages.count, 1)
            
            let trackChangeMsg = self.trackChangeMessages.first!
            XCTAssertEqual(trackChangeMsg.oldTrack, self.sequencer.selectionTracksByIndex[trackIndex]!)
            XCTAssertEqual(trackChangeMsg.oldState, PlaybackState.waiting)
            XCTAssertEqual(trackChangeMsg.newTrack, self.sequencer.selectionTracksByIndex[trackIndex]!)
        }
    }
    
    func testTogglePlayPause_transcoding() {
        
        let trackIndex: Int = 10
        
        // Specify an "ogg" file extension to trigger track transcoding
        sequencer.selectionTracksByIndex[trackIndex] = createTrack("TestTrack", "ogg", 300)
        
        // Begin playback
        delegate.play(trackIndex)
        
        XCTAssertEqual(delegate.state, PlaybackState.transcoding)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectionTracksByIndex[trackIndex]!)
        XCTAssertNil(delegate.waitingTrack)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, delegate.playingTrack!)
        
        // Try to request immediate playback (should have no effect)
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.transcoding)
        XCTAssertEqual(delegate.playingTrack, sequencer.selectionTracksByIndex[trackIndex])
        XCTAssertNil(delegate.waitingTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 0)
        }
    }
}
