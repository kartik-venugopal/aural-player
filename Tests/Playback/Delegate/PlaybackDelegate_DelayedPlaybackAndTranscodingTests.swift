import XCTest

class PlaybackDelegate_DelayedPlaybackAndTranscodingTests: PlaybackDelegateTests {
    
    // MARK: play() tests -----------------------------------------------------------------------------
    
    func testPlay_delayAndTranscoding_delayShorterThanTranscoding() {
        
        let track = createTrack("Enchantment", "wma", 180)
        doBeginPlaybackWithDelay(track, 2)
        
        assertWaitingTrack(track)
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
        
        assertWaitingTrack(track)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        executeAfter(1) {
            
            // Prepare track and signal transcoding finished
            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))
            
            usleep(500000)
            
            // Track should still be waiting and ready for playback when the delay ends
            XCTAssertTrue(track.lazyLoadingInfo.preparedForPlayback)
            self.assertWaitingTrack(track)
        }
        
        executeAfter(3.5) {
            self.assertPlayingTrack(track)
        }
    }
    
    // MARK: Track completion tests -----------------------------------------------------------------------------

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
            self.assertWaitingTrack(subsequentTrack)
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
            self.assertWaitingTrack(subsequentTrack)
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
            self.assertWaitingTrack(subsequentTrack)
            
            // 2 + 4 = 6 seconds total delay
            XCTAssertEqual(self.startPlaybackChain.executedContext!.delay, 6)
        }
        
        executeAfter(6) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
}
