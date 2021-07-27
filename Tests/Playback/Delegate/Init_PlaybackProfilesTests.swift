//
//  Init_PlaybackProfilesTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class Init_PlaybackProfilesTests: PlaybackDelegateTests {

    // Create a PlaybackDelegate instance with no playback profiles
    func testInit_noProfiles() {

//        Messenger.unsubscribeAll(for: startPlaybackChain)
//
        let profiles = PlaybackProfiles([])

        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences)
        stopPlaybackChain = TestableStopPlaybackChain(player, playlist, sequencer, profiles, preferences)
        trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)

        let testDelegate = PlaybackDelegate(player, sequencer, profiles, preferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)

        XCTAssertEqual(testDelegate.profiles.size, 0)
//
//        Messenger.unsubscribeAll(for: testDelegate)
//        Messenger.unsubscribeAll(for: startPlaybackChain)
    }

    // Create a PlaybackDelegate instance with some playback profiles
    func testInit_withProfiles() {

//        Messenger.unsubscribeAll(for: startPlaybackChain)
//
        let track1 = createTrack(title: "Strangelove", duration: 300)
        let track2 = createTrack(title: "Money for Nothing", duration: 420)

        let profile1 = PlaybackProfile(track1.file, 102.25345345)
        let profile2 = PlaybackProfile(track2.file, 257.93487834)

        let profiles = PlaybackProfiles([])
        let profilesArr: [PlaybackProfile] = [profile1, profile2]

        for profile in profilesArr {
            profiles[profile.file] = profile
        }

        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences)
        stopPlaybackChain = TestableStopPlaybackChain(player, playlist, sequencer, profiles, preferences)
        trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)

        let testDelegate = PlaybackDelegate(player, sequencer, profiles, preferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)

        XCTAssertEqual(testDelegate.profiles.size, 2)

        let profileForTrack1 = testDelegate.profiles[track1]
        XCTAssertEqual(profileForTrack1!.file, track1.file)
        XCTAssertEqual(profileForTrack1!.lastPosition, profile1.lastPosition)

        let profileForTrack2 = testDelegate.profiles[track2]
        XCTAssertEqual(profileForTrack2!.file, track2.file)
        XCTAssertEqual(profileForTrack2!.lastPosition, profile2.lastPosition)
//
//        Messenger.unsubscribeAll(for: testDelegate)
//        Messenger.unsubscribeAll(for: startPlaybackChain)
    }
}
