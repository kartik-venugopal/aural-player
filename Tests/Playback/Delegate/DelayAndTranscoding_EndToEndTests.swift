import XCTest

class DelayAndTranscoding_EndToEndTests: PlaybackDelegateTests {
    
    // MARK: play() tests -----------------------------------------------------------------------------
    
    func testPlay_delayAndTranscoding_delayShorterThanTranscoding() {
        
        let track = createTrack("Enchantment", "wma", 180)
        doBeginPlaybackWithDelay(track, 2)
        
        assertWaitingTrack(track, 2)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        executeAfter(3) {
            
            // Gap has completed, now the track should be transcoding
            self.assertTranscodingTrack(track)
            
            // Prepare track and signal transcoding finished
            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))
            
            usleep(500000)
            
            // Track should now be playing
            self.assertPlayingTrack(track)
        }
    }
    
    func testPlay_delayAndTranscoding_delayLongerThanTranscoding() {
        
        let track = createTrack("Odyssey", "wma", 180)
        doBeginPlaybackWithDelay(track, 4)
        
        assertWaitingTrack(track, 4)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        executeAfter(1) {
            
            // Prepare track and signal transcoding finished
            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))
            
            usleep(500000)
            
            // Track should still be waiting and ready for playback when the delay ends
            XCTAssertTrue(track.lazyLoadingInfo.preparedForPlayback)
            self.assertWaitingTrack(track, 4)
        }
        
        executeAfter(3.5) {
            self.assertPlayingTrack(track)
        }
    }
    
    // MARK: Track completion tests -----------------------------------------------------------------------------
    
    func testTrackCompletion_noSubsequentTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        sequencer.subsequentTrack = nil
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 1)
            XCTAssertEqual(self.stopPlaybackChain.executionCount, 1)
            
            self.assertNoTrack()
        }
    }
    
    func testTrackCompletion_noDelay() {
        
        let track = createTrack("Money for Nothing", 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        preferences.gapBetweenTracks = false
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            self.assertPlayingTrack(subsequentTrack)
        }
    }

    func testTrackCompletion_gapBetweenTracks() {
        
        let track = createTrack("Money for Nothing", 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 3
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            self.assertWaitingTrack(subsequentTrack, 3)
        }
        
        executeAfter(3) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapAfterCompletedTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        
        let gapAfterCompletedTrack = PlaybackGap(3, .afterTrack)
        playlist.setGapsForTrack(track, nil, gapAfterCompletedTrack)
        XCTAssertEqual(playlist.getGapAfterTrack(track), gapAfterCompletedTrack)
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            self.assertWaitingTrack(subsequentTrack, 3)
        }
        
        executeAfter(3) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapAfterCompletedTrack_gapBeforeNewTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        
        let gapAfterCompletedTrack = PlaybackGap(2, .afterTrack)
        playlist.setGapsForTrack(track, nil, gapAfterCompletedTrack)
        XCTAssertEqual(playlist.getGapAfterTrack(track), gapAfterCompletedTrack)
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        let gapBeforeSubsequentTrack = PlaybackGap(4, .afterTrack)
        playlist.setGapsForTrack(subsequentTrack, gapBeforeSubsequentTrack, nil)
        XCTAssertEqual(playlist.getGapBeforeTrack(subsequentTrack), gapBeforeSubsequentTrack)
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            // 2 + 4 = 6 seconds total delay
            self.assertWaitingTrack(subsequentTrack, 6)
        }
        
        executeAfter(6) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapBeforeNewTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        XCTAssertNil(playlist.getGapAfterTrack(track))
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        let gapBeforeSubsequentTrack = PlaybackGap(4, .afterTrack)
        playlist.setGapsForTrack(subsequentTrack, gapBeforeSubsequentTrack, nil)
        XCTAssertEqual(playlist.getGapBeforeTrack(subsequentTrack), gapBeforeSubsequentTrack)
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            // 0 + 4 = 4 seconds total delay
            self.assertWaitingTrack(subsequentTrack, 4)
        }
        
        executeAfter(4) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapBeforeNewTrack_newTrackNeedsTranscoding_transcodingTimeLongerThanDelay() {
        
        let track = createTrack("Money for Nothing", 420)
        XCTAssertNil(playlist.getGapAfterTrack(track))
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", "wma", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        let gapBeforeSubsequentTrack = PlaybackGap(3, .afterTrack)
        playlist.setGapsForTrack(subsequentTrack, gapBeforeSubsequentTrack, nil)
        XCTAssertEqual(playlist.getGapBeforeTrack(subsequentTrack), gapBeforeSubsequentTrack)
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(PlaybackSession.currentSession!))
        
        executeAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            // 0 + 3 = 3 seconds total delay
            self.assertWaitingTrack(subsequentTrack, 3)
        }
        
        executeAfter(3) {
            
            // Delay should be over, new track should be transcoding
            self.assertTranscodingTrack(subsequentTrack)
        }
        
        executeAfter(2) {
            
            // Prepare track and signal transcoding finished
            subsequentTrack.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(subsequentTrack, true))
            
            usleep(500000)
            
            // Track should still be waiting and ready for playback when the delay ends
            XCTAssertTrue(subsequentTrack.lazyLoadingInfo.preparedForPlayback)
            self.assertPlayingTrack(subsequentTrack)
        }
    }
}
