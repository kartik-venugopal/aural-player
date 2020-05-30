import XCTest

class PlaybackDelegate_MessageHandlingTests: PlaybackDelegateTests {
    
    private var trackNotTranscodedMsgCount: Int = 0
    private var trackNotTranscodedMsg_track: Track?
    private var trackNotTranscodedMsg_error: InvalidTrackError?
    
    override func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackNotTranscodedMsg = message as? TrackNotTranscodedAsyncMessage {
            
            trackNotTranscodedMsgCount.increment()
            trackNotTranscodedMsg_track = trackNotTranscodedMsg.track
            trackNotTranscodedMsg_error = trackNotTranscodedMsg.error
            
            return
        }
    }
    
    override func tearDown() {
        
        // To prevent delegate instances from previous test runs from consuming messages intended for other test runs
        
        AsyncMessenger.unsubscribe([.playbackCompleted, .transcodingFinished], subscriber: delegate)
        AsyncMessenger.unsubscribe([.trackNotTranscoded], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.savePlaybackProfile, .deletePlaybackProfile], subscriber: delegate)
    }
    
    // MARK: .playbackCompleted tests ----------------------------------------------------------------------------

    func testConsumeAsyncMessage_playbackCompleted_expiredSession() {
        
        let track = createTrack("Strangelove", 300)
        let expiredSession = PlaybackSession.start(track)
        XCTAssertTrue(PlaybackSession.isCurrent(expiredSession))
        
        let track2 = createTrack("Money for Nothing", 420)
        let currentSession = PlaybackSession.start(track2)
        
        XCTAssertTrue(PlaybackSession.isCurrent(currentSession))
        XCTAssertFalse(PlaybackSession.isCurrent(expiredSession))
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(expiredSession))
        
        asyncOnMainAfter(0.5) {
            
            // Message should have been ignored because the session has expired
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 0)
        }
    }
    
    func testConsumeAsyncMessage_playbackCompleted_currentSession() {
        
        let track = createTrack("Money for Nothing", 420)
        let currentSession = PlaybackSession.start(track)
        
        XCTAssertTrue(PlaybackSession.isCurrent(currentSession))
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(currentSession))
        
        asyncOnMainAfter(0.5) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
        }
    }
    
    // MARK: .transcodingFinished tests ----------------------------------------------------------------------------
    
    func testConsumeAsyncMessage_transcodingFinished_success() {
        
        AsyncMessenger.subscribe([.trackNotTranscoded], subscriber: self, dispatchQueue: .main)
        
        let track = createTrack("Money for Nothing", 420)
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))
        
        asyncOnMainAfter(0.5) {
            
            // Message should have been ignored
            XCTAssertEqual(self.stopPlaybackChain.executionCount, 0)
            XCTAssertEqual(self.trackNotTranscodedMsgCount, 0)
        }
    }
    
    func testConsumeAsyncMessage_transcodingFinished_failure() {
        
        AsyncMessenger.subscribe([.trackNotTranscoded], subscriber: self, dispatchQueue: .main)
        
        let track = createTrack("Money for Nothing", 420)
        track.lazyLoadingInfo.preparationError = TranscodingFailedError(track)
        
        // Publish a message for the delegate to process
        AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, false))
        
        asyncOnMainAfter(0.5) {
            
            // Message should have been processed
            XCTAssertEqual(self.stopPlaybackChain.executionCount, 1)
            
            XCTAssertEqual(self.trackNotTranscodedMsgCount, 1)
            XCTAssertEqual(self.trackNotTranscodedMsg_track, track)
            XCTAssertTrue(self.trackNotTranscodedMsg_error! is TranscodingFailedError)
            XCTAssertEqual(self.trackNotTranscodedMsg_error!.track, track)
        }
    }
    
    // MARK: .savePlaybackProfile tests ----------------------------------------------------------------------------
    
    func testConsumeMessage_savePlaybackProfile_noProfileYet() {
        
        let track = createTrack("Money for Nothing", 420)
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Check that no playback profile exists yet, for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        
        // Set the player's seek position to a specific value that will be saved to the new playback profile
        mockScheduler.seekPosition = 27.9349894387
        XCTAssertEqual(delegate.seekPosition.timeElapsed, mockScheduler.seekPosition)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save)
        
        let newProfile = delegate.profiles.get(track)!
        XCTAssertEqual(newProfile.file, track.file)
        XCTAssertEqual(newProfile.lastPosition, mockScheduler.seekPosition, accuracy: 0.001)
    }
    
    func testConsumeMessage_savePlaybackProfile_profileExistsAndIsOverwritten() {

        // Save a profile for the track, representing a pre-existing playback profile.
        let track = createTrack("Money for Nothing", 420)
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, oldProfile)
        
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Verify that a playback profile already exists for the playing track
        XCTAssertNotNil(delegate.profiles.get(track))
        
        // Set the player's seek position to a specific value that will be saved to the new playback profile
        mockScheduler.seekPosition = 27.9349894387
        XCTAssertEqual(delegate.seekPosition.timeElapsed, mockScheduler.seekPosition)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save)
        
        // Verify that the new profile has replaced the old one
        let newProfile = delegate.profiles.get(track)!
        XCTAssertEqual(newProfile.file, track.file)
        
        XCTAssertEqual(newProfile.lastPosition, mockScheduler.seekPosition, accuracy: 0.001)
        XCTAssertNotEqual(newProfile.lastPosition, oldProfile.lastPosition)
    }
    
    // MARK: .deletePlaybackProfile tests ----------------------------------------------------------------------------
    
    func testConsumeMessage_deletePlaybackProfile_noProfileYet() {
        
        let track = createTrack("Money for Nothing", 420)
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Check that no playback profile exists yet, for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)

        // After the delete, no profile should exist for the playing track
        XCTAssertNil(delegate.profiles.get(track))
    }
    
    func testConsumeMessage_deletePlaybackProfile_profileExistsAndIsOverwritten() {

        // Save a profile for the track, representing a pre-existing playback profile.
        let track = createTrack("Money for Nothing", 420)
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, oldProfile)
        
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Verify that a playback profile already exists for the playing track
        XCTAssertNotNil(delegate.profiles.get(track))
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)

        // After the delete, no profile should exist for the playing track
        XCTAssertNil(delegate.profiles.get(track))
    }
}
