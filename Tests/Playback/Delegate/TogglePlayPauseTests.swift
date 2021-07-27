//
//  TogglePlayPauseTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class TogglePlayPauseTests: PlaybackDelegateTests {

    func testTogglePlayPause_noTrackPlaying_emptyPlaylist() {
        doBeginPlayback(nil)
    }

    func testTogglePlayPause_noTrackPlaying_playbackBegins() {
        doBeginPlayback(createTrack(title: "TestTrack", duration: 300))
    }

    func testTogglePlayPause_playing_pausesPlayback() {

        let track = createTrack(title: "TestTrack", duration: 300)

        doBeginPlayback(track)
        doPausePlayback(track)
    }

    func testTogglePlayPause_paused_resumesPlayback() {

        let track = createTrack(title: "TestTrack", duration: 300)

        doBeginPlayback(track)
        doPausePlayback(track)
        doResumePlayback(track)
    }
}
