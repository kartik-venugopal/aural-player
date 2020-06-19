import XCTest

class ForcedSeekingTests: PlaybackDelegateTests {
    
    // MARK: seekToPercentage() tests ------------------------------------------------------------------------
    
    func testSeekToPercentage_noPlayingTrack() {
        
        for percentage: Double in [0, 1, 5, 10, 25, 50, 75, 100] {
            
            assertNoTrack()
            delegate.seekToPercentage(percentage)
            
            assertNoTrack()
            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        }
    }
    
    func testSeekToPercentage_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        for percentage: Double in [0, 1, 5, 10, 25, 50, 75, 100] {
            
            delegate.seekToPercentage(percentage)
            
            assertWaitingTrack(track, 5)
            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        }
    }
    
    func testSeekToPercentage_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "ogg", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        for percentage: Double in [0, 1, 5, 10, 25, 50, 75, 100] {
            
            delegate.seekToPercentage(percentage)
            
            assertTranscodingTrack(track)
            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        }
    }
    
    func testSeekToPercentage_trackPaused() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...1000 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        var seekPercentages: Set<Double> = Set([0, 1, 2, 3, 5, 10, 25, 50, 100])
        
        for _ in 1...100 {
            seekPercentages.insert(Double.random(in: 0...100))
        }
        
        for trackDuration in trackDurations {
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            for seekPercentage in seekPercentages {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekToPercentage_trackPaused(track, seekPercentage)
            }
        }
    }
    
    private func doSeekToPercentage_trackPaused(_ track: Track, _ percentage: Double) {
        
        let seekToTimeCallCountBefore = player.forceSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        delegate.seekToPercentage(percentage)
        
        assertPausedTrack(track, true)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        
        let expectedSeekPosition = Double(percentage) * track.duration / 100.0
        XCTAssertEqual(player.forceSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        XCTAssertFalse(player.forceSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekToPercentage() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...1000 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        var seekPercentages: Set<Double> = Set([0, 1, 2, 3, 5, 10, 25, 50, 100])
        
        for _ in 1...100 {
            seekPercentages.insert(Double.random(in: 0...100))
        }
        
        for trackDuration in trackDurations {
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            for seekPercentage in seekPercentages {
                
                delegate.play(track)
                doSeekToPercentage(track, seekPercentage)
            }
        }
    }
    
    private func doSeekToPercentage(_ track: Track, _ percentage: Double) {
        
        let seekToTimeCallCountBefore = player.forceSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        delegate.seekToPercentage(percentage)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        
        let expectedSeekPosition = Double(percentage) * track.duration / 100.0
        XCTAssertEqual(player.forceSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        let trackCompleted: Bool = expectedSeekPosition >= track.duration
        XCTAssertEqual(player.forceSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))
        
        if !trackCompleted {
            assertPlayingTrack(track, true)
        }
    }
    
    private var loopChangedMsgCount: Int = 0
    
    func loopChanged() {
        loopChangedMsgCount.increment()
    }
    
    func testSeekToPercentage_loopRemoved() {
        
        // Don't want track change notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        // Subscribe to loop change messages
        Messenger.subscribe(self, .player_playbackLoopChanged, self.loopChanged)
        
        let track = createTrack("Like a Virgin", 250)
        
        let loopStartTime: Double = 25
        let loopEndTime: Double = 50
        
        let params = PlaybackParams.defaultParams().withStartAndEndPosition(loopStartTime, loopEndTime)
        
        // Play the track with a start/end position (i.e. loop)
        delegate.play(track, params)
        
        // Verify track is playing and a complete loop is defined.
        assertPlayingTrack(track)
        XCTAssertTrue(delegate.playbackLoop!.isComplete)
        
        // Perform the seek
        // 5% is outside the loop (before loop start time)
        let percentage: Double = 5
        delegate.seekToPercentage(percentage)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        
        let expectedSeekPosition = percentage * track.duration / 100.0
        XCTAssertEqual(player.forceSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        // Ensure track is still playing and loop has been removed
        assertPlayingTrack(track)
        XCTAssertNil(delegate.playbackLoop)
        
        XCTAssertTrue(player.forceSeekResult!.loopRemoved)
        XCTAssertFalse(player.forceSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(loopChangedMsgCount, 1)
    }
    
    func testSeekToPercentage_trackCompletion_noNewTrack() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        // After the seek takes the first track to completion, this track should begin playing.
        sequencer.subsequentTrack = nil
        
        // Perform the seek
        delegate.seekToPercentage(100)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        XCTAssertEqual(player.forceSeekToTime_time!, track.duration, accuracy: 0.001)
        
        // Verify track playback completion
        
        assertNoTrack()
        
        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        self.assertTrackChange(track, .playing, nil, 2)
    }
    
    func testSeekToPercentage_trackCompletion_newTrack() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        // After the seek takes the first track to completion, this track should begin playing.
        let subsequentTrack = createTrack("Strangers by Night", 305.123986345)
        sequencer.subsequentTrack = subsequentTrack
        
        // Perform the seek
        delegate.seekToPercentage(100)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        XCTAssertEqual(player.forceSeekToTime_time!, track.duration, accuracy: 0.001)
        
        // Verify track playback completion
        
        assertPlayingTrack(subsequentTrack)
        
        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        
        self.assertTrackChange(track, .playing, subsequentTrack, 2)
    }
    
    // MARK: seekToTime() tests ------------------------------------------------------------------------
    
    func testSeekToTime_noPlayingTrack() {
        
        assertNoTrack()
        delegate.seekToTime(10)
        
        assertNoTrack()
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
    }
    
    func testSeekToTime_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.seekToTime(10)
        
        assertWaitingTrack(track, 5)
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
    }
    
    func testSeekToTime_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "ogg", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.seekToTime(10)
        
        assertTranscodingTrack(track)
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
    }
    
    func testSeekToTime_trackPaused() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...1000 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        for trackDuration in trackDurations {
            
            var seekTimes: Set<Double> = Set([0, trackDuration])
            
            for _ in 1...100 {
                seekTimes.insert(Double.random(in: 0...trackDuration))
            }
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            for seekTime in seekTimes {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekToTime_trackPaused(track, seekTime)
            }
        }
    }
    
    private func doSeekToTime_trackPaused(_ track: Track, _ seekTime: Double) {
        
        let seekToTimeCallCountBefore = player.forceSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        delegate.seekToTime(seekTime)
        
        assertPausedTrack(track, true)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        
        XCTAssertEqual(player.forceSeekToTime_time!, seekTime, accuracy: 0.001)
        
        XCTAssertFalse(player.forceSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekToTime() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...1000 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        for trackDuration in trackDurations {
            
            var seekTimes: Set<Double> = Set([0, trackDuration])
            
            for _ in 1...100 {
                seekTimes.insert(Double.random(in: 0...trackDuration))
            }
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            for seekTime in seekTimes {
                
                delegate.play(track)
                doSeekToTime(track, seekTime)
            }
        }
    }
    
    private func doSeekToTime(_ track: Track, _ seekTime: Double) {
        
        let seekToTimeCallCountBefore = player.forceSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        delegate.seekToTime(seekTime)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        
        XCTAssertEqual(player.forceSeekToTime_time!, seekTime, accuracy: 0.001)
        
        let trackCompleted: Bool = seekTime >= track.duration
        XCTAssertEqual(player.forceSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))
        
        if !trackCompleted {
            assertPlayingTrack(track, true)
        }
    }
    
    func testSeekToTime_loopRemoved() {
        
        // Don't want track change notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        // Subscribe to loop change messages
        Messenger.subscribe(self, .player_playbackLoopChanged, self.loopChanged)
        
        let track = createTrack("Like a Virgin", 250)
        
        let loopStartTime: Double = 25
        let loopEndTime: Double = 50
        
        let params = PlaybackParams.defaultParams().withStartAndEndPosition(loopStartTime, loopEndTime)
        
        // Play the track with a start/end position (i.e. loop)
        delegate.play(track, params)
        
        // Verify track is playing and a complete loop is defined.
        assertPlayingTrack(track)
        XCTAssertTrue(delegate.playbackLoop!.isComplete)
        
        // Perform the seek
        // 5% is outside the loop (before loop start time)
        let seekTime: Double = 15
        delegate.seekToTime(seekTime)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        
        XCTAssertEqual(player.forceSeekToTime_time!, seekTime, accuracy: 0.001)
        
        // Ensure track is still playing and loop has been removed
        assertPlayingTrack(track)
        XCTAssertNil(delegate.playbackLoop)
        
        XCTAssertTrue(player.forceSeekResult!.loopRemoved)
        XCTAssertFalse(player.forceSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(loopChangedMsgCount, 1)
    }
    
    func testSeekToTime_trackCompletion_noNewTrack() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        // After the seek takes the first track to completion, this track should begin playing.
        sequencer.subsequentTrack = nil
        
        // Perform the seek
        delegate.seekToTime(track.duration)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        XCTAssertEqual(player.forceSeekToTime_time!, track.duration, accuracy: 0.001)
        
        // Verify track playback completion
        
        assertNoTrack()
        
        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        self.assertTrackChange(track, .playing, nil, 2)
    }
    
    func testSeekToTime_trackCompletion_newTrack() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        // After the seek takes the first track to completion, this track should begin playing.
        let subsequentTrack = createTrack("Strangers by Night", 305.123986345)
        sequencer.subsequentTrack = subsequentTrack
        
        // Perform the seek
        delegate.seekToTime(track.duration)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_track!, track)
        XCTAssertEqual(player.forceSeekToTime_time!, track.duration, accuracy: 0.001)
        
        // Verify track playback completion
        
        assertPlayingTrack(subsequentTrack)
        
        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        
        self.assertTrackChange(track, .playing, subsequentTrack, 2)
    }
}
