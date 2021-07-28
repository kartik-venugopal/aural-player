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

        profiles = PlaybackProfiles([])
        preferences = PlaybackPreferences([:])

        action = SavePlaybackProfileAction(profiles, preferences)
        chain = MockPlaybackChain()
    }

    func testSavePlaybackProfileAction_noTrackPlaying() {

        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, PlaybackParams.defaultParams())

        XCTAssertEqual(profiles.size, 0)

        action.execute(context, chain)

        XCTAssertEqual(profiles.size, 0)
        assertChainProceeded(context)
    }

    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForAllTracks_noProfileForPlayingTrack() {

        let currentTrack: Track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // No profile for the current track
        XCTAssertNil(profiles[currentTrack])
        XCTAssertEqual(profiles.size, 0)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)

        // Verify that a new profile is created
        let newProfile = profiles[currentTrack]!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)

        assertChainProceeded(context)
    }

    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForAllTracks_playingTrackHasProfile() {

        let currentTrack: Track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles[currentTrack] = oldProfile

        XCTAssertTrue(profiles[currentTrack]! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)

        // Verify that a new profile is created
        let newProfile = profiles[currentTrack]!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)

        assertChainProceeded(context)
    }

    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForIndividualTracks_noProfileForPlayingTrack() {

        let currentTrack: Track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // No profile for the current track
        XCTAssertNil(profiles[currentTrack])
        XCTAssertEqual(profiles.size, 0)

        // Set this option to true for individual tracks so only tracks with profiles will remember their last playback positions.
        preferences.rememberLastPositionOption = .individualTracks

        action.execute(context, chain)

        // Verify that no profile is created for the current track (because it doesn't already have a profile)
        XCTAssertNil(profiles[currentTrack])
        XCTAssertEqual(profiles.size, 0)

        assertChainProceeded(context)
    }

    func testSavePlaybackProfileAction_trackPlaying_rememberLastPositionForIndividualTracks_playingTrackHasProfile() {

        let currentTrack: Track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles[currentTrack] = oldProfile

        XCTAssertTrue(profiles[currentTrack]! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for individual tracks so only tracks with profiles will remember their last playback positions.
        preferences.rememberLastPositionOption = .individualTracks

        action.execute(context, chain)

        // Verify that a new profile is created
        let newProfile = profiles[currentTrack]!
        XCTAssertEqual(newProfile.file, currentTrack.file)
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)

        assertChainProceeded(context)
    }

    func testSavePlaybackProfileAction_currentPositionEqualToTrackDuration_resetTo0() {

        let currentTrack: Track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles[currentTrack] = oldProfile

        XCTAssertTrue(profiles[currentTrack]! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for individual tracks so only tracks with profiles will remember their last playback positions.
        preferences.rememberLastPositionOption = .individualTracks

        action.execute(context, chain)

        // Verify that a new profile is created
        let newProfile = profiles[currentTrack]!
        XCTAssertEqual(newProfile.file, currentTrack.file)

        // Last position should have been reset to 0 since the track finished playing (i.e. seek position reached track duration)
        XCTAssertEqual(newProfile.lastPosition, 0, accuracy: 0.001)

        XCTAssertEqual(profiles.size, 1)

        assertChainProceeded(context)
    }

    func testSavePlaybackProfileAction_trackPaused() {

        let currentTrack: Track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let context = PlaybackRequestContext(.paused, currentTrack, 185.234234, requestedTrack, PlaybackParams.defaultParams())

        // Add a profile for the current track
        let oldProfile = PlaybackProfile(currentTrack, 137.9327973429)
        profiles[currentTrack] = oldProfile

        XCTAssertTrue(profiles[currentTrack]! === oldProfile)
        XCTAssertEqual(profiles.size, 1)

        // Set this option to true for all tracks so that the last playback position will be remembered for any playing track
        preferences.rememberLastPositionOption = .allTracks

        action.execute(context, chain)

        // Verify that a new profile is created
        let newProfile = profiles[currentTrack]!
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
