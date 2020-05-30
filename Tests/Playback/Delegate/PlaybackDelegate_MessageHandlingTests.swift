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
    
    func testConsumeMessage_savePlaybackProfile_noTrack() {
        
        assertNoTrack()
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save)
        
        XCTAssertEqual(delegate.profiles.all().count, 0)
    }
    
    func testConsumeMessage_savePlaybackProfile_noProfileYet() {
        
        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack("Walk of Life", 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles.add(otherTrack.file, profile)
        
        let track = createTrack("Money for Nothing", 420)
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Check that no playback profile exists yet, for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        
        // Verify that only 1 profile exists - the profile for the non-playing track
        XCTAssertEqual(delegate.profiles.all().count, 1)
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
        
        // Set the player's seek position to a specific value that will be saved to the new playback profile
        mockScheduler.seekPosition = 27.9349894387
        XCTAssertEqual(delegate.seekPosition.timeElapsed, mockScheduler.seekPosition)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save)
        
        let newProfile = delegate.profiles.get(track)!
        XCTAssertEqual(newProfile.file, track.file)
        XCTAssertEqual(newProfile.lastPosition, mockScheduler.seekPosition, accuracy: 0.001)
        
        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.all().count, 2)
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
    }
    
    func testConsumeMessage_savePlaybackProfile_profileExistsAndIsOverwritten() {
        
        // TODO: Create a profile for a non-playing track, and later verify that it has remained unchanged by the save.
        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack("Walk of Life", 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles.add(otherTrack.file, profile)

        // Save a profile for the track, representing a pre-existing playback profile.
        let track = createTrack("Money for Nothing", 420)
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, oldProfile)
        
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Verify that both profiles exist
        XCTAssertNotNil(delegate.profiles.get(track))
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
        XCTAssertEqual(delegate.profiles.all().count, 2)
        
        // Set the player's seek position to a specific value that will be saved to the new playback profile
        mockScheduler.seekPosition = 27.9349894387
        XCTAssertEqual(delegate.seekPosition.timeElapsed, mockScheduler.seekPosition)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save)
        
        // Verify that the new profile has replaced the old one
        let newProfile = delegate.profiles.get(track)!
        XCTAssertEqual(newProfile.file, track.file)
        
        XCTAssertEqual(newProfile.lastPosition, mockScheduler.seekPosition, accuracy: 0.001)
        XCTAssertNotEqual(newProfile.lastPosition, oldProfile.lastPosition)
        
        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.all().count, 2)
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
    }
    
    // MARK: .deletePlaybackProfile tests ----------------------------------------------------------------------------
    
    func testConsumeMessage_deletePlaybackProfile_noPlayingTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, profile)
        
        assertNoTrack()
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)
        
        // Previously added profile should remain undeleted.
        XCTAssertEqual(delegate.profiles.all().count, 1)
    }
    
    func testConsumeMessage_deletePlaybackProfile_noProfileYet() {
        
        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack("Walk of Life", 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles.add(otherTrack.file, profile)
        
        let track = createTrack("Money for Nothing", 420)
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Check that no playback profile exists yet, for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        
        // Verify that a playback profile already exists for the other track
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
        
        // Verify that only one profile exists
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)

        // After the delete, no profile should exist for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        
        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.all().count, 1)
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
    }
    
    func testConsumeMessage_deletePlaybackProfile_profileExistsAndIsDeleted() {
        
        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack("Walk of Life", 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles.add(otherTrack.file, profile)

        // Save a profile for the playing track, representing a pre-existing playback profile.
        let track = createTrack("Money for Nothing", 420)
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, oldProfile)
        
        delegate.play(track)
        assertPlayingTrack(track)
        
        // Verify that a playback profile already exists for the playing track and for the other track
        XCTAssertNotNil(delegate.profiles.get(track))
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
        
        // Verify that both profiles exist
        XCTAssertEqual(delegate.profiles.all().count, 2)
        
        SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)

        // After the delete, no profile should exist for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        
        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.all().count, 1)
        XCTAssertNotNil(delegate.profiles.get(otherTrack))
    }
    
    // MARK: .appExitRequest tests ----------------------------------------------------------------------------
    
    func testOnAppExit_noTrackPlaying() {
        
        assertNoTrack()
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackWaiting_noProfile() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        XCTAssertNil(delegate.playingTrack)
        
        // No profile for track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackWaiting_hasProfile_unchanged() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        XCTAssertNil(delegate.playingTrack)
        
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, oldProfile)
        
        XCTAssertNotNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // Verify that the old profile is unchanged (because the track was in a waiting state).
        let newProfile = delegate.profiles.get(track)!
        XCTAssertEqual(newProfile.file, track.file)
        XCTAssertEqual(newProfile.lastPosition, oldProfile.lastPosition, accuracy: 0.001)
        
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackTranscoding_noProfile() {
        
        let track = createTrack("So Far Away", "wma", 300)
        delegate.play(track)
        XCTAssertNil(delegate.playingTrack)
        
        // No profile for track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // No profile was saved for track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackTranscoding_hasProfile_unchanged() {
        
        let track = createTrack("So Far Away", "wma", 300)
        delegate.play(track)
        XCTAssertNil(delegate.playingTrack)
        
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, oldProfile)
        
        XCTAssertNotNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // Verify that the old profile is unchanged (because the track was in a transcoding state).
        let newProfile = delegate.profiles.get(track)!
        XCTAssertEqual(newProfile.file, track.file)
        XCTAssertEqual(newProfile.lastPosition, oldProfile.lastPosition, accuracy: 0.001)
        
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackPlaying_rememberLastPositionOptionOff() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)
        
        // No profile for playing track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        // Set this option to false so that the last playback position will not be remembered for the playing track
        preferences.rememberLastPosition = false
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackPlaying_rememberLastPositionForAllTracks_noProfileForPlayingTrack() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)
        
        // No profile for playing track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        mockScheduler.seekPosition = 101.92929292
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // Verify that a profile was saved for the playing track, with the right seek position
        let profile = delegate.profiles.get(track)
        XCTAssertEqual(profile!.file, track.file)
        XCTAssertEqual(profile!.lastPosition, delegate.seekPosition.timeElapsed)
        
        XCTAssertEqual(delegate.profiles.all().count, 1)
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackPlaying_rememberLastPositionForAllTracks_playingTrackHasProfile() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)
        
        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, profile)
        
        XCTAssertNotNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks
        
        mockScheduler.seekPosition = 101.92929292
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // Verify that the existing profile was updated for the playing track
        let updatedProfile = delegate.profiles.get(track)
        XCTAssertEqual(updatedProfile!.file, track.file)
        XCTAssertEqual(updatedProfile!.lastPosition, delegate.seekPosition.timeElapsed)
        
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackPlaying_rememberLastPositionForIndividualTracks_noProfileForPlayingTrack() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)
        
        // No profile for playing track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        // Set this option to true for individual tracks (any track having a profile will remember its playback position)
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
        mockScheduler.seekPosition = 101.92929292
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // Verify that no profile was saved for the playing track
        XCTAssertNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 0)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
    
    func testOnAppExit_trackPlaying_rememberLastPositionForIndividualTracks_playingTrackHasProfile() {
        
        let track = createTrack("So Far Away", 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)
        
        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles.add(track.file, profile)
        
        XCTAssertNotNil(delegate.profiles.get(track))
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        // Set this option to true for individual tracks (any track having a profile will remember its playback position)
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
        mockScheduler.seekPosition = 101.92929292
        
        let response = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        // Verify that the existing profile was updated for the playing track
        let updatedProfile = delegate.profiles.get(track)
        XCTAssertEqual(updatedProfile!.file, track.file)
        XCTAssertEqual(updatedProfile!.lastPosition, delegate.seekPosition.timeElapsed)
        
        XCTAssertEqual(delegate.profiles.all().count, 1)
        
        XCTAssertTrue((response[0] as! AppExitResponse).okToExit)
    }
}
