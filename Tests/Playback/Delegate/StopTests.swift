//
//  StopTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class StopTests: PlaybackDelegateTests {
    
    func testStop_noPlayingTrack() {
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
    }
    
    func testStop_trackPlaying() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.playing, track, seekPosBeforeChange)
        
        self.assertTrackChange(track, .playing, nil, 2)
    }
    
    func testStop_trackPaused() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        doPausePlayback(track)
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.paused, track, seekPosBeforeChange)
        
        self.assertTrackChange(track, .paused, nil, 2)
    }
    
    func testStop_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.waiting, track, 0)
        
        XCTAssertNil(stopPlaybackChain.executedContext!.delay)
        
        self.assertTrackChange(track, .waiting, nil)
    }
    
    func testStop_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "wma", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.transcoding, track, 0)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track!, track)
        
        self.assertTrackChange(track, .transcoding, nil)
    }
}
