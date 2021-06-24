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
        doBeginPlayback(createTrack("TestTrack", 300))
    }
    
    func testTogglePlayPause_playing_pausesPlayback() {
        
        let track = createTrack("TestTrack", 300)
        
        doBeginPlayback(track)
        doPausePlayback(track)
    }
    
    func testTogglePlayPause_paused_resumesPlayback() {
        
        let track = createTrack("TestTrack", 300)
        
        doBeginPlayback(track)
        doPausePlayback(track)
        doResumePlayback(track)
    }
    
    func testTogglePlayPause_gapBeforeTrack() {
        
        let track = createTrack("TestTrack", 300)
        
        // Set a gap before the track (in the playlist)
        playlist.setGapsForTrack(track, PlaybackGap(5, .beforeTrack, .persistent), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(track))

        // Begin playback
        sequencer.beginTrack = track
        delegate.togglePlayPause()
        assertWaitingTrack(track, 5)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.beginCallCount, 1)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
        self.assertGapStarted(nil, track)
    }
    
    func testTogglePlayPause_trackNeedsTranscoding() {
        doBeginPlayback_trackNeedsTranscoding(createTrack("TestTrack", "ogg", 300))
    }
    
    func testTogglePlayPause_waiting_immediatePlayback() {
        
        let track = createTrack("TestTrack", 300)
        doBeginPlaybackWithDelay(track, 5)
        
        // Cancel the delay and request immediate playback
        delegate.togglePlayPause()
        assertPlayingTrack(track)
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        
        self.assertTrackChange(track, .waiting, track)
    }
    
    func testTogglePlayPause_transcoding() {
        
        let track = createTrack("TestTrack", "ogg", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        // Try to request immediate playback (should have no effect)
        delegate.togglePlayPause()
        assertTranscodingTrack(track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
        XCTAssertEqual(self.gapStartedMessages.count, 0)
    }
}
