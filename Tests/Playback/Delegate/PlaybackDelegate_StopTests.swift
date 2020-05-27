import XCTest

class PlaybackDelegate_StopTests: PlaybackDelegateTests {

    func testStop_noPlayingTrack() {
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, nil)
        }
    }
    
    func testStop_trackPlaying() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .playing, nil, 2)
        }
    }
    
    func testStop_trackPaused() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        doPausePlayback(track)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .paused, nil, 2)
        }
    }
    
    func testStop_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .waiting, nil)
        }
    }
    
    func testStop_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "wma", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .transcoding, nil)
        }
    }
}
