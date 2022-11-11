//
//  PlaybackDelegateTests+InitPlaybackProfiles.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_InitPlaybackProfiles: PlaybackDelegateTestCase {
    
    // Create a PlaybackDelegate instance with no playback profiles
    func testInit_noProfiles() {

        let profiles = PlaybackProfiles([])

        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences)
        stopPlaybackChain = TestableStopPlaybackChain(player, playlist, sequencer, profiles, preferences)
        trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)

        let testDelegate = PlaybackDelegate(player, sequencer, profiles, preferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)

        XCTAssertEqual(testDelegate.profiles.size, 0)
        
        testDelegate.stopListeningForMessages()
    }

    // Create a PlaybackDelegate instance with some playback profiles
    func testInit_withProfiles() {

        let track1 = createTrack(title: "Strangelove", duration: 300)
        let track2 = createTrack(title: "Money for Nothing", duration: 420)

        let profile1 = PlaybackProfile(track1, 102.25345345)
        let profile2 = PlaybackProfile(track2, 257.93487834)

        let profiles = PlaybackProfiles([profile1, profile2])

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
        
        testDelegate.stopListeningForMessages()
    }
}
