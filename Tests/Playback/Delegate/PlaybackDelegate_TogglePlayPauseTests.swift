import XCTest

class PlaybackDelegate_TogglePlayPauseTests: PlaybackDelegateTests {

    func testTogglePlayPause_noTrackPlaying_emptyPlaylist() {
        doBeginPlayback(nil)
    }
    
    func testTogglePlayPause_noTrackPlaying_playbackBegins() {
        doBeginPlayback(createTrack("TestTrack", 300))
    }
    
    func testTogglePlayPause_playing_pausesPlayback() {
        
        let track = createTrack("TestTrack", 300)
        doBeginPlayback(track)
        doPausePlayback(track)
    }
    
    func testTogglePlayPause_paused_resumesPlayback() {
        
        let track = createTrack("TestTrack", 300)
        
        doBeginPlayback(track)
        doPausePlayback(track)
        doResumePlayback(track)
    }
    
    func testTogglePlayPause_waiting_immediatePlayback() {
        
        let trackIndex: Int = 10
        let track = createTrack("TestTrack", 300)
        sequencer.selectionTracksByIndex[trackIndex] = track
        
        // Begin playback with a delay
        delegate.play(trackIndex, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertEqual(sequencer.selectIndexCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        assertWaitingTrack(track)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            self.assertGapStarted(nil, track)
        }
        
        // Cancel the delay and request immediate playback
        delegate.togglePlayPause()
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .waiting, track)
        }
    }
    
    func testTogglePlayPause_transcoding() {
        
        let trackIndex: Int = 10
        let track = createTrack("TestTrack", "ogg", 300)
        
        // Specify an "ogg" file extension to trigger track transcoding
        sequencer.selectionTracksByIndex[trackIndex] = track
        
        // Begin playback
        delegate.play(trackIndex)
        
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        // Try to request immediate playback (should have no effect)
        delegate.togglePlayPause()
        
        assertTranscodingTrack(track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 0)
        }
    }
}
