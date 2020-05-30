import XCTest

class PlaybackDelegate_PropertyGettersTests: PlaybackDelegateTests {

    // MARK: state tests -------------------------------------------------------------------------------------
    
    func testPlaybackState_noTrack() {
        
        delegate.stop()
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
    }
    
    func testPlaybackState_playing() {
        
        delegate.play(createTrack("So Far Away", 300))
        XCTAssertEqual(delegate.state, PlaybackState.playing)
    }
    
    func testPlaybackState_paused() {
        
        delegate.play(createTrack("So Far Away", 300))
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        
        delegate.togglePlayPause()
        XCTAssertEqual(delegate.state, PlaybackState.paused)
    }
    
    func testPlaybackState_pausedAndResumed() {
        
        delegate.play(createTrack("So Far Away", 300))
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        
        delegate.togglePlayPause()
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        delegate.togglePlayPause()
        XCTAssertEqual(delegate.state, PlaybackState.playing)
    }
    
    func testPlaybackState_waiting() {
        
        delegate.play(createTrack("So Far Away", 300), PlaybackParams.defaultParams().withDelay(5))
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
    }
    
    func testPlaybackState_transcoding() {
        
        delegate.play(createTrack("So Far Away", "ogg", 300))
        XCTAssertEqual(delegate.state, PlaybackState.transcoding)
    }
    
    // MARK: currentTrack tests -------------------------------------------------------------------------------------
    
    func testCurrentTrack_noTrack() {
        
        delegate.stop()
        XCTAssertNil(delegate.currentTrack)
    }
    
    func testCurrentTrack_playing() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        
        XCTAssertEqual(delegate.currentTrack!, track)
    }
    
    func testCurrentTrack_paused() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.currentTrack!, track)
        
        delegate.togglePlayPause()
        XCTAssertEqual(delegate.currentTrack!, track)
    }
    
    func testCurrentTrack_waiting() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertEqual(delegate.currentTrack!, track)
    }
    
    func testCurrentTrack_transcoding() {
        
        let track = createTrack("So Far Away", "ogg", 300)
        delegate.play(track)
        
        XCTAssertEqual(delegate.currentTrack!, track)
    }
    
    // MARK: playingTrack tests -------------------------------------------------------------------------------------
    
    func testPlayingTrack_noTrack() {
        
        delegate.stop()
        XCTAssertNil(delegate.playingTrack)
    }
    
    func testPlayingTrack_playing() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        
        XCTAssertEqual(delegate.playingTrack!, track)
    }
    
    func testPlayingTrack_paused() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)
        
        delegate.togglePlayPause()
        XCTAssertEqual(delegate.playingTrack!, track)
    }
    
    func testPlayingTrack_waiting() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertNil(delegate.playingTrack)
    }
    
    func testPlayingTrack_transcoding() {
        
        let track = createTrack("So Far Away", "ogg", 300)
        delegate.play(track)
        
        XCTAssertNil(delegate.playingTrack)
    }
    
    // MARK: waitingTrack tests -------------------------------------------------------------------------------------
    
    func testWaitingTrack_noTrack() {
        
        delegate.stop()
        XCTAssertNil(delegate.waitingTrack)
    }
    
    func testWaitingTrack_playing() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        
        XCTAssertNil(delegate.waitingTrack)
    }
    
    func testWaitingTrack_paused() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertNil(delegate.waitingTrack)
        
        delegate.togglePlayPause()
        XCTAssertNil(delegate.waitingTrack)
    }
    
    func testWaitingTrack_waiting() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertEqual(delegate.waitingTrack!, track)
    }
    
    func testWaitingTrack_transcoding() {
        
        let track = createTrack("So Far Away", "ogg", 300)
        delegate.play(track)
        
        XCTAssertNil(delegate.waitingTrack)
    }
    
    // MARK: transcodingTrack tests -------------------------------------------------------------------------------------
    
    func testTranscodingTrack_noTrack() {
        
        delegate.stop()
        XCTAssertNil(delegate.transcodingTrack)
    }
    
    func testTranscodingTrack_playing() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        
        XCTAssertNil(delegate.transcodingTrack)
    }
    
    func testTranscodingTrack_paused() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertNil(delegate.transcodingTrack)
        
        delegate.togglePlayPause()
        XCTAssertNil(delegate.transcodingTrack)
    }
    
    func testTranscodingTrack_waiting() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        
        XCTAssertNil(delegate.transcodingTrack)
    }
    
    func testTranscodingTrack_transcoding() {
        
        let track = createTrack("So Far Away", "ogg", 300)
        delegate.play(track)
        
        XCTAssertEqual(delegate.transcodingTrack!, track)
    }
}
