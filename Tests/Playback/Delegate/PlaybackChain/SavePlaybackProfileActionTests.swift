//
//  SavePlaybackProfileActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SavePlaybackProfileActionTests: AuralTestCase {

    var action: SavePlaybackProfileAction!
    var chain: MockPlaybackChain!
    
    var profiles: PlaybackProfiles!
    var preferences: PlaybackPreferences!
    
    override func setUp() {
        
        profiles = PlaybackProfiles()
        preferences = PlaybackPreferences([:])
        
        action = SavePlaybackProfileAction(profiles, preferences)
        chain = MockPlaybackChain()
    }
    
    func testSavePlaybackProfileAction_noTrackPlaying() {
        
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, PlaybackParams.defaultParams())
        
        XCTAssertEqual(profiles.size, 0)
        
        action.execute(context, chain)
        
        XCTAssertEqual(profiles.size, 0)
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackWaiting_noProfile() {

        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        XCTAssertEqual(profiles.size, 0)
        
        action.execute(context, chain)
        
        XCTAssertEqual(profiles.size, 0)
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackWaiting_hasProfile_unchanged() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)
        
        // Verify that the old profile is unchanged (because the track was in a waiting state).
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, oldProfile.lastPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackTranscoding_noProfile() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        XCTAssertEqual(profiles.size, 0)
        
        action.execute(context, chain)
        
        XCTAssertEqual(profiles.size, 0)
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackTranscoding_hasProfile_unchanged() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)
        
        // Verify that the old profile is unchanged (because the track was in a waiting state).
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, oldProfile.lastPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionOptionOff() {
      
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to false to disable saving of playback profiles
        preferences.rememberLastPosition = false

        action.execute(context, chain)
        
        // Verify that the old profile is unchanged (because the remember last position option was set to an off state).
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, oldProfile.lastPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForAllTracks_noProfileForPlayingTrack() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // No profile for the current track
        XCTAssertNil(profiles.get(currentTrack))
        XCTAssertEqual(profiles.size, 0)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)
        
        // Verify that a new profile is created
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForAllTracks_playingTrackHasProfile() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)
        
        // Verify that a new profile is created
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForIndividualTracks_noProfileForPlayingTrack() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // No profile for the current track
        XCTAssertNil(profiles.get(currentTrack))
        XCTAssertEqual(profiles.size, 0)

        // Set this option to true for individual tracks so only tracks with profiles will remember their last playback positions.
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks

        action.execute(context, chain)
        
        // Verify that no profile is created for the current track (because it doesn't already have a profile)
        XCTAssertNil(profiles.get(currentTrack))
        XCTAssertEqual(profiles.size, 0)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForIndividualTracks_playingTrackHasProfile() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for individual tracks so only tracks with profiles will remember their last playback positions.
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks

        action.execute(context, chain)
        
        // Verify that a new profile is created
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_currentPositionEqualToTrackDuration_resetTo0() {
        
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for individual tracks so only tracks with profiles will remember their last playback positions.
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks

        action.execute(context, chain)
        
        // Verify that a new profile is created
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        
        // Last position should have been reset to 0 since the track finished playing (i.e. seek position reached track duration)
        XCTAssertEqual(newProfile.lastPosition, 0, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    func testSavePlaybackProfileAction_trackPaused() {
    
        let currentTrack: Track = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        let context = PlaybackRequestContext(.paused, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles.add(currentTrack, oldProfile)

        XCTAssertTrue(profiles.get(currentTrack)! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)
        
        // Verify that a new profile is created
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)
        
        assertChainProceeded(context)
    }
    
    private func assertChainProceeded(_ context: PlaybackRequestContext) {
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
}
