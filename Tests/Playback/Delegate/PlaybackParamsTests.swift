//
//  PlaybackParamsTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackParamsTests: PlaybackDelegateTests {
    
    func testParams_allowDelay_explicitDelay() {
        
        let delay = 5.0
        let params = PlaybackParams.defaultParams().withAllowDelay(true).withDelay(delay)
        XCTAssertTrue(params.allowDelay)
        XCTAssertEqual(params.delay, delay)
        
        let track = createTrack("Like a Virgin", 249)
        delegate.play(track, params)
        
        assertWaitingTrack(track, delay)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
        self.assertGapStarted(nil, track)
    }
    
    func testParams_dontAllowDelay_explicitDelay() {
        
        let delay = 5.0
        let params = PlaybackParams.defaultParams().withAllowDelay(false).withDelay(delay)
        XCTAssertFalse(params.allowDelay)
        XCTAssertEqual(params.delay, delay)
        
        let track = createTrack("Like a Virgin", 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
        XCTAssertEqual(self.gapStartedMessages.count, 0)
    }
    
    func testParams_allowDelay_gapBeforeTrack() {
        
        let track = createTrack("Like a Virgin", 249)
        
        let params = PlaybackParams.defaultParams().withAllowDelay(true)
        XCTAssertTrue(params.allowDelay)
        XCTAssertNil(params.delay)
        
        // Set a gap before the track (in the playlist)
        let gapBeforeTrack = 5.0
        playlist.setGapsForTrack(track, PlaybackGap(gapBeforeTrack, .beforeTrack, .persistent), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        
        delegate.play(track, params)
        
        assertWaitingTrack(track, gapBeforeTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
        self.assertGapStarted(nil, track)
    }
    
    func testParams_dontAllowDelay_gapBeforeTrack() {
        
        let track = createTrack("Like a Virgin", 249)
        
        let params = PlaybackParams.defaultParams().withAllowDelay(false)
        XCTAssertFalse(params.allowDelay)
        XCTAssertNil(params.delay)
        
        // Set a gap before the track (in the playlist)
        let gapBeforeTrack = 5.0
        playlist.setGapsForTrack(track, PlaybackGap(gapBeforeTrack, .beforeTrack, .persistent), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
        XCTAssertEqual(self.gapStartedMessages.count, 0)
    }
    
    // Bookmark playback
    func testParams_noStartPosition_startAt0() {
        
        let track = createTrack("Like a Virgin", 249)
        
        let params = PlaybackParams.defaultParams()
        XCTAssertNil(params.startPosition)
        
        delegate.play(track, params)
        assertPlayingTrack(track)
        
        XCTAssertTrue(mockScheduler.playTrackInvoked)
        XCTAssertEqual(mockScheduler.playTrack_startPosition, 0)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    // Bookmark playback
    func testParams_startPosition() {
        
        let track = createTrack("Like a Virgin", 249)
        let startPosition = 37.8674673
        
        let params = PlaybackParams.defaultParams().withStartPosition(startPosition)
        XCTAssertEqual(params.startPosition, startPosition)
        
        delegate.play(track, params)
        assertPlayingTrack(track)
        
        XCTAssertTrue(mockScheduler.playTrackInvoked)
        XCTAssertEqual(mockScheduler.playTrack_startPosition!, startPosition, accuracy: 0.001)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    // Bookmarked loop playback
    func testParams_startAndEndPosition() {
        
        let track = createTrack("Like a Virgin", 249)
        let startPosition = 37.8674673
        let endPosition = 62.3243456
        
        let params = PlaybackParams.defaultParams().withStartAndEndPosition(startPosition, endPosition)
        XCTAssertEqual(params.startPosition, startPosition)
        XCTAssertEqual(params.endPosition, endPosition)
        
        delegate.play(track, params)
        assertPlayingTrack(track)
        
        XCTAssertTrue(mockScheduler.playLoopInvoked)
        XCTAssertEqual(mockScheduler.playLoop_session!.loop!.startTime, startPosition, accuracy: 0.001)
        XCTAssertEqual(mockScheduler.playLoop_session!.loop!.endTime!, endPosition, accuracy: 0.001)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testParams_interruptPlayback_noTrackPlaying() {
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(true)
        XCTAssertTrue(params.interruptPlayback)
        
        let track = createTrack("Like a Virgin", 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testParams_interruptPlayback_trackPlaying() {
        
        let firstTrack = createTrack("FirstTrack", 251.2425346343)
        doBeginPlayback(firstTrack)
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(true)
        XCTAssertTrue(params.interruptPlayback)
        
        let track = createTrack("Like a Virgin", 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 2)
    }
    
    func testParams_dontInterruptPlayback_noTrackPlaying() {
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(false)
        XCTAssertFalse(params.interruptPlayback)
        
        let track = createTrack("Like a Virgin", 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testParams_dontInterruptPlayback_trackPlaying() {
        
        let firstTrack = createTrack("FirstTrack", 251.2425346343)
        doBeginPlayback(firstTrack)
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(false)
        XCTAssertFalse(params.interruptPlayback)
        
        let track = createTrack("Like a Virgin", 249)
        delegate.play(track, params)
        
        // New track should not have begun playing (first track should still be playing)
        assertPlayingTrack(firstTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
}
