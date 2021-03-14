import XCTest

class PropertyGettersTests: PlaybackDelegateTests {

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
    
    // MARK: seekPosition tests -------------------------------------------------------------------------------------
    
    func testSeekPosition_noTrackPlaying() {
        
        delegate.stop()
        assertNoTrack()
        
        let delegateSeekPosition = delegate.seekPosition
        
        XCTAssertEqual(delegateSeekPosition.timeElapsed, 0, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.percentageElapsed, 0, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.trackDuration, 0, accuracy: 0.001)
    }
    
    func testSeekPosition_trackWaiting() {
        
        delegate.play(createTrack("So Far Away", 300), PlaybackParams.defaultParams().withDelay(5))
        XCTAssertNil(delegate.playingTrack)
        
        let delegateSeekPosition = delegate.seekPosition
        
        XCTAssertEqual(delegateSeekPosition.timeElapsed, 0, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.percentageElapsed, 0, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.trackDuration, 0, accuracy: 0.001)
    }
    
    func testSeekPosition_trackTranscoding() {
        
        delegate.play(createTrack("So Far Away", "ogg", 300))
        XCTAssertNil(delegate.playingTrack)
        
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
            
            let track = createTrack("So Far Away", trackDuration)
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
            
            let track = createTrack("So Far Away", trackDuration)
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
        
        mockScheduler.seekPosition = seekPos
        
        let delegateSeekPosition = delegate.seekPosition
        
        XCTAssertEqual(delegateSeekPosition.timeElapsed, seekPos, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.percentageElapsed, seekPos * 100 / track.duration, accuracy: 0.001)
        XCTAssertEqual(delegateSeekPosition.trackDuration, track.duration, accuracy: 0.001)
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
        _ = PlaybackSession.start(createTrack("So Far Away", 300))
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        XCTAssertNotNil(PlaybackSession.currentSession?.timestamp)
        
        // Verify that the delegate's playingTrackStartTime property matches the timestamp of the new playback session
        XCTAssertEqual(delegate.playingTrackStartTime!, PlaybackSession.currentSession!.timestamp, accuracy: 0.001)
    }
}
