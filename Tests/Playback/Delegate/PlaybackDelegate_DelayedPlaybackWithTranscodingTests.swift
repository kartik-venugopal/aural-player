import XCTest

class PlaybackDelegate_DelayedPlaybackWithTranscodingTests: PlaybackDelegateTests {
    
    override func tearDown() {
        
        super.tearDown()
        
        let prepAction: PlaybackChainAction =
            startPlaybackChain.actions.filter({$0 is AudioFilePreparationAction}).first!
        
        AsyncMessenger.unsubscribe([.transcodingFinished], subscriber: prepAction as! AudioFilePreparationAction)
    }

    func testPlay_delayAndTranscoding_delayShorterThanTranscoding() {
        
        let track = createTrack("Enchantment", "wma", 180)
        doBeginPlaybackWithDelay(track, 2)
        
        assertWaitingTrack(track)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        let exp = expectation(description: "Track is playing")
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 3) {
            
            // Gap has completed, now the track should be transcoding
            self.assertTranscodingTrack(track)
            
            // Prepare track and signal transcoding finished
            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))

            usleep(500000)

            // Track should now be playing
            self.assertPlayingTrack(track)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 6)
    }
    
//    func testPlay_delayAndTranscoding_delayLongerThanTranscoding() {
//
//        let track = createTrack("Odyssey", "wma", 180)
//        doBeginPlaybackWithDelay(track, 4)
//
//        assertWaitingTrack(track)
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
//        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
//
//        let exp1 = expectation(description: "Track is waiting")
//
//        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
//
//            // Prepare track and signal transcoding finished
//            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
//            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))
//
//            usleep(500000)
//
//            // Track should still be waiting
//            self.assertWaitingTrack(track)
//
//            exp1.fulfill()
//        }
//
//        wait(for: [exp1], timeout: 2)
//
//        let exp2 = expectation(description: "Track is playing")
//
//        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 3.5) {
//
//            self.assertPlayingTrack(track)
//            exp2.fulfill()
//        }
//
//        wait(for: [exp2], timeout: 4)
//    }
    
//    func testPlay_delayAndTranscoding_delayAndTranscodingRoughlyEqualDuration() {
//
//    }
}
