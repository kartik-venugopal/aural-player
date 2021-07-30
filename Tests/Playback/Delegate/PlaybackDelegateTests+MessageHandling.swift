//
//  PlaybackDelegateTests+MessageHandling.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_MessageHandling: PlaybackDelegateTestCase {
    
    var trackNotPlayedMsgCount: Int = 0
    var trackNotPlayedMsg_oldTrack: Track?
    var trackNotPlayedMsg_error: DisplayableError?
    
    func trackNotPlayed(_ notif: TrackNotPlayedNotification) {

        trackNotPlayedMsgCount.increment()
        trackNotPlayedMsg_oldTrack = notif.errorTrack
        trackNotPlayedMsg_error = notif.error
    }
    
    // MARK: .playbackCompleted tests ----------------------------------------------------------------------------

    func testConsumeAsyncMessage_playbackCompleted_expiredSession() {
        
        let track = createTrack(title: "Strangelove", duration: 300)
        let expiredSession = PlaybackSession.start(track)
        XCTAssertTrue(PlaybackSession.isCurrent(expiredSession))
        
        let track2 = createTrack(title: "Money for Nothing", duration: 420)
        let currentSession = PlaybackSession.start(track2)
        
        XCTAssertTrue(PlaybackSession.isCurrent(currentSession))
        XCTAssertFalse(PlaybackSession.isCurrent(expiredSession))
        
        // Publish a message for the delegate to process
        messenger.publish(.player_trackPlaybackCompleted, payload: expiredSession)
        
        executeAfter(0.2) {
            
            // Message should have been ignored because the session has expired
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 0)
        }
    }
    
    func testConsumeAsyncMessage_playbackCompleted_expiredSession_trackHasPlaybackProfile() {

        let track = createTrack(title: "Strangelove", duration: 300)
        let expiredSession = PlaybackSession.start(track)
        XCTAssertTrue(PlaybackSession.isCurrent(expiredSession))

        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = profile

        XCTAssertNotNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 1)

        // Set this option to true for individual tracks (any track having a profile will remember its playback position)
        preferences.rememberLastPositionOption = .individualTracks

        mockPlayerNode._seekPosition = track.duration

        let track2 = createTrack(title: "Money for Nothing", duration: 420)
        let currentSession = PlaybackSession.start(track2)

        XCTAssertTrue(PlaybackSession.isCurrent(currentSession))
        XCTAssertFalse(PlaybackSession.isCurrent(expiredSession))

        // Publish a message for the delegate to process
        messenger.publish(.player_trackPlaybackCompleted, payload: expiredSession)

        executeAfter(0.2) {

            // Message should have been ignored because the session has expired
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 0)

            // Verify that the existing profile was updated for the playing track
            let updatedProfile = self.delegate.profiles[track]
            XCTAssertEqual(updatedProfile!.file, track.file)

            // Position should have been reset to 0 because the seek position had crossed the track's duration (i.e. the track completed playback)
            XCTAssertEqual(updatedProfile!.lastPosition, 0)

            XCTAssertEqual(self.delegate.profiles.size, 1)
        }
    }

    func testConsumeAsyncMessage_playbackCompleted_currentSession() {

        let track = createTrack(title: "Money for Nothing", duration: 420)
        doBeginPlayback(track)

        XCTAssertTrue(PlaybackSession.hasCurrentSession())

        let seekPosBeforeChange = delegate.seekPosition.timeElapsed

        // Publish a message for the delegate to process
        messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)

        executeAfter(0.2) {

            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            self.verifyRequestContext_trackPlaybackCompletedChain(.playing, track, seekPosBeforeChange)
        }
    }

    // MARK: .savePlaybackProfile tests ----------------------------------------------------------------------------

    func testConsumeMessage_savePlaybackProfile_noTrack() {

        assertNoTrack()
        XCTAssertEqual(delegate.profiles.size, 0)

        messenger.publish(.player_savePlaybackProfile)

        XCTAssertEqual(delegate.profiles.size, 0)
    }

    func testConsumeMessage_savePlaybackProfile_noProfileYet() {

        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack(title: "Walk of Life", duration: 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles[otherTrack.file] = profile

        let track = createTrack(title: "Money for Nothing", duration: 420)
        delegate.play(track)
        assertPlayingTrack(track)

        // Check that no playback profile exists yet, for the playing track
        XCTAssertNil(delegate.profiles[track])

        // Verify that only 1 profile exists - the profile for the non-playing track
        XCTAssertEqual(delegate.profiles.size, 1)
        XCTAssertNotNil(delegate.profiles[otherTrack])

        // Set the player's seek position to a specific value that will be saved to the new playback profile
        mockPlayerNode._seekPosition = 27.9349894387
        XCTAssertEqual(delegate.seekPosition.timeElapsed, mockPlayerNode.seekPosition)

        messenger.publish(.player_savePlaybackProfile)

        let newProfile = delegate.profiles[track]!
        XCTAssertEqual(newProfile.file, track.file)
        XCTAssertEqual(newProfile.lastPosition, mockPlayerNode.seekPosition, accuracy: 0.001)

        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.size, 2)
        XCTAssertNotNil(delegate.profiles[otherTrack])
    }

    func testConsumeMessage_savePlaybackProfile_profileExistsAndIsOverwritten() {

        // TODO: Create a profile for a non-playing track, and later verify that it has remained unchanged by the save.
        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack(title: "Walk of Life", duration: 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles[otherTrack.file] = profile

        // Save a profile for the track, representing a pre-existing playback profile.
        let track = createTrack(title: "Money for Nothing", duration: 420)
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = oldProfile

        delegate.play(track)
        assertPlayingTrack(track)

        // Verify that both profiles exist
        XCTAssertNotNil(delegate.profiles[track])
        XCTAssertNotNil(delegate.profiles[otherTrack])
        XCTAssertEqual(delegate.profiles.size, 2)

        // Set the player's seek position to a specific value that will be saved to the new playback profile
        mockPlayerNode._seekPosition = 27.9349894387
        XCTAssertEqual(delegate.seekPosition.timeElapsed, mockPlayerNode.seekPosition)

        messenger.publish(.player_savePlaybackProfile)

        // Verify that the new profile has replaced the old one
        let newProfile = delegate.profiles[track]!
        XCTAssertEqual(newProfile.file, track.file)

        XCTAssertEqual(newProfile.lastPosition, mockPlayerNode.seekPosition, accuracy: 0.001)
        XCTAssertNotEqual(newProfile.lastPosition, oldProfile.lastPosition)

        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.size, 2)
        XCTAssertNotNil(delegate.profiles[otherTrack])
    }

    // MARK: .deletePlaybackProfile tests ----------------------------------------------------------------------------

    func testConsumeMessage_deletePlaybackProfile_noPlayingTrack() {

        let track = createTrack(title: "Money for Nothing", duration: 420)
        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = profile

        assertNoTrack()
        XCTAssertEqual(delegate.profiles.size, 1)

        messenger.publish(.player_deletePlaybackProfile)

        // Previously added profile should remain undeleted.
        XCTAssertEqual(delegate.profiles.size, 1)
    }

    func testConsumeMessage_deletePlaybackProfile_noProfileYet() {

        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack(title: "Walk of Life", duration: 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles[otherTrack.file] = profile

        let track = createTrack(title: "Money for Nothing", duration: 420)
        delegate.play(track)
        assertPlayingTrack(track)

        // Check that no playback profile exists yet, for the playing track
        XCTAssertNil(delegate.profiles[track])

        // Verify that a playback profile already exists for the other track
        XCTAssertNotNil(delegate.profiles[otherTrack])

        // Verify that only one profile exists
        XCTAssertEqual(delegate.profiles.size, 1)

        messenger.publish(.player_deletePlaybackProfile)

        // After the delete, no profile should exist for the playing track
        XCTAssertNil(delegate.profiles[track])

        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.size, 1)
        XCTAssertNotNil(delegate.profiles[otherTrack])
    }

    func testConsumeMessage_deletePlaybackProfile_profileExistsAndIsDeleted() {

        // Save a profile for a track other than the playing track, representing a pre-existing playback profile.
        let otherTrack = createTrack(title: "Walk of Life", duration: 300)
        let profile = PlaybackProfile(otherTrack.file, 62.4258643)
        delegate.profiles[otherTrack.file] = profile

        // Save a profile for the playing track, representing a pre-existing playback profile.
        let track = createTrack(title: "Money for Nothing", duration: 420)
        let oldProfile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = oldProfile

        delegate.play(track)
        assertPlayingTrack(track)

        // Verify that a playback profile already exists for the playing track and for the other track
        XCTAssertNotNil(delegate.profiles[track])
        XCTAssertNotNil(delegate.profiles[otherTrack])

        // Verify that both profiles exist
        XCTAssertEqual(delegate.profiles.size, 2)

        messenger.publish(.player_deletePlaybackProfile)

        // After the delete, no profile should exist for the playing track
        XCTAssertNil(delegate.profiles[track])

        // Verify that the profile for the non-playing track still exists.
        XCTAssertEqual(delegate.profiles.size, 1)
        XCTAssertNotNil(delegate.profiles[otherTrack])
    }

    // MARK: .appExitRequest tests ----------------------------------------------------------------------------

    func testOnAppExit_noTrackPlaying() {

        assertNoTrack()
        XCTAssertEqual(delegate.profiles.size, 0)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPositionOption = .allTracks

        messenger.publish(.application_willExit)

        XCTAssertEqual(delegate.profiles.size, 0)
    }

    func testOnAppExit_trackPlaying_rememberLastPositionForAllTracks_noProfileForPlayingTrack() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        // No profile for playing track
        XCTAssertNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 0)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPositionOption = .allTracks

        mockPlayerNode._seekPosition = 101.92929292

        messenger.publish(.application_willExit)

        // Verify that a profile was saved for the playing track, with the right seek position
        let profile = delegate.profiles[track]
        XCTAssertEqual(profile!.file, track.file)
        XCTAssertEqual(profile!.lastPosition, delegate.seekPosition.timeElapsed)

        XCTAssertEqual(delegate.profiles.size, 1)
    }

    func testOnAppExit_trackPlaying_rememberLastPositionForAllTracks_playingTrackHasProfile() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = profile

        XCTAssertNotNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPositionOption = .allTracks

        mockPlayerNode._seekPosition = 101.92929292

        messenger.publish(.application_willExit)

        // Verify that the existing profile was updated for the playing track
        let updatedProfile = delegate.profiles[track]
        XCTAssertEqual(updatedProfile!.file, track.file)
        XCTAssertEqual(updatedProfile!.lastPosition, delegate.seekPosition.timeElapsed)

        XCTAssertEqual(delegate.profiles.size, 1)
    }

    func testOnAppExit_trackPlaying_rememberLastPositionForIndividualTracks_noProfileForPlayingTrack() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        // No profile for playing track
        XCTAssertNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 0)

        // Set this option to true for individual tracks (any track having a profile will remember its playback position)
        preferences.rememberLastPositionOption = .individualTracks

        mockPlayerNode._seekPosition = 101.92929292

        messenger.publish(.application_willExit)

        // Verify that no profile was saved for the playing track
        XCTAssertNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 0)
    }

    func testOnAppExit_trackPlaying_rememberLastPositionForIndividualTracks_playingTrackHasProfile() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = profile

        XCTAssertNotNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 1)

        // Set this option to true for individual tracks (any track having a profile will remember its playback position)
        preferences.rememberLastPositionOption = .individualTracks

        mockPlayerNode._seekPosition = 101.92929292

        messenger.publish(.application_willExit)

        // Verify that the existing profile was updated for the playing track
        let updatedProfile = delegate.profiles[track]
        XCTAssertEqual(updatedProfile!.file, track.file)
        XCTAssertEqual(updatedProfile!.lastPosition, delegate.seekPosition.timeElapsed)

        XCTAssertEqual(delegate.profiles.size, 1)
    }

    func testOnAppExit_trackPlaying_rememberLastPositionForIndividualTracks_positionResetTo0() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        let profile = PlaybackProfile(track.file, 137.9327973429)
        delegate.profiles[track.file] = profile

        XCTAssertNotNil(delegate.profiles[track])
        XCTAssertEqual(delegate.profiles.size, 1)

        // Set this option to true for individual tracks (any track having a profile will remember its playback position)
        preferences.rememberLastPositionOption = .individualTracks

        mockPlayerNode._seekPosition = track.duration

        messenger.publish(.application_willExit)

        // Verify that the existing profile was updated for the playing track
        let updatedProfile = delegate.profiles[track]
        XCTAssertEqual(updatedProfile!.file, track.file)

        // Position should have been reset to 0 because the seek position had crossed the track's duration (i.e. the track completed playback)
        XCTAssertEqual(updatedProfile!.lastPosition, 0)

        XCTAssertEqual(delegate.profiles.size, 1)
    }
}
