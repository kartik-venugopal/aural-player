//
//  PlaybackDelegateTests+PlaybackParams.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_PlaybackParams: PlaybackDelegateTestCase {
    
    // Bookmark playback
    func testParams_noStartPosition_startAt0() {
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
        
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
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
        let startPosition = 37.8674673
        
        let params = PlaybackParams.defaultParams().withStartAndEndPosition(startPosition)
        XCTAssertEqual(params.startPosition, startPosition)
        
        delegate.play(track, params)
        assertPlayingTrack(track)
        
        XCTAssertTrue(mockScheduler.playTrackInvoked)
        XCTAssertEqual(mockScheduler.playTrack_startPosition!, startPosition, accuracy: 0.001)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    // Bookmarked loop playback
    func testParams_startAndEndPosition() {
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
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
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testParams_interruptPlayback_trackPlaying() {
        
        let firstTrack = createTrack(title: "FirstTrack", duration: 251.2425346343)
        doBeginPlayback(firstTrack)
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(true)
        XCTAssertTrue(params.interruptPlayback)
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 2)
    }
    
    func testParams_dontInterruptPlayback_noTrackPlaying() {
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(false)
        XCTAssertFalse(params.interruptPlayback)
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
        delegate.play(track, params)
        
        assertPlayingTrack(track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
    
    func testParams_dontInterruptPlayback_trackPlaying() {
        
        let firstTrack = createTrack(title: "FirstTrack", duration: 251.2425346343)
        doBeginPlayback(firstTrack)
        
        let params = PlaybackParams.defaultParams().withInterruptPlayback(false)
        XCTAssertFalse(params.interruptPlayback)
        
        let track = createTrack(title: "Like a Virgin", duration: 249)
        delegate.play(track, params)
        
        // New track should not have begun playing (first track should still be playing)
        assertPlayingTrack(firstTrack)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 1)
    }
}
