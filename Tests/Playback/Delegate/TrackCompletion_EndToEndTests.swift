//
//  TrackCompletion_EndToEndTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class TrackCompletion_EndToEndTests: PlaybackDelegateTests {
    
    // TODO: Add more cases from TrackCompletionTests

    // MARK: Track completion tests -----------------------------------------------------------------------------
    
    func testTrackCompletion_noSubsequentTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        sequencer.subsequentTrack = nil
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 1)
            XCTAssertEqual(self.stopPlaybackChain.executionCount, 1)
            
            self.assertNoTrack()
        }
    }
    
    func testTrackCompletion_noDelay() {
        
        let track = createTrack("Money for Nothing", 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        preferences.gapBetweenTracks = false
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            self.assertPlayingTrack(subsequentTrack)
        }
    }

    func testTrackCompletion_gapBetweenTracks() {
        
        let track = createTrack("Money for Nothing", 420)
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 3
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            self.assertWaitingTrack(subsequentTrack, 3)
        }
        
        executeAfter(3) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapAfterCompletedTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        
        let gapAfterCompletedTrack = PlaybackGap(3, .afterTrack)
        playlist.setGapsForTrack(track, nil, gapAfterCompletedTrack)
        XCTAssertEqual(playlist.getGapAfterTrack(track), gapAfterCompletedTrack)
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            self.assertWaitingTrack(subsequentTrack, 3)
        }
        
        executeAfter(3) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapAfterCompletedTrack_gapBeforeNewTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        
        let gapAfterCompletedTrack = PlaybackGap(2, .afterTrack)
        playlist.setGapsForTrack(track, nil, gapAfterCompletedTrack)
        XCTAssertEqual(playlist.getGapAfterTrack(track), gapAfterCompletedTrack)
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        let gapBeforeSubsequentTrack = PlaybackGap(4, .afterTrack)
        playlist.setGapsForTrack(subsequentTrack, gapBeforeSubsequentTrack, nil)
        XCTAssertEqual(playlist.getGapBeforeTrack(subsequentTrack), gapBeforeSubsequentTrack)
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            // 2 + 4 = 6 seconds total delay
            self.assertWaitingTrack(subsequentTrack, 6)
        }
        
        executeAfter(6) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapBeforeNewTrack() {
        
        let track = createTrack("Money for Nothing", 420)
        XCTAssertNil(playlist.getGapAfterTrack(track))
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        let gapBeforeSubsequentTrack = PlaybackGap(4, .afterTrack)
        playlist.setGapsForTrack(subsequentTrack, gapBeforeSubsequentTrack, nil)
        XCTAssertEqual(playlist.getGapBeforeTrack(subsequentTrack), gapBeforeSubsequentTrack)
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            // 0 + 4 = 4 seconds total delay
            self.assertWaitingTrack(subsequentTrack, 4)
        }
        
        executeAfter(4) {
            
            // Delay should be over, new track should be playing
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    func testTrackCompletion_gapBeforeNewTrack_newTrackNeedsTranscoding_transcodingTimeLongerThanDelay() {
        
        let track = createTrack("Money for Nothing", 420)
        XCTAssertNil(playlist.getGapAfterTrack(track))
        
        doBeginPlayback(track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        let subsequentTrack = createTrack("Private Investigations", "wma", 360)
        sequencer.subsequentTrack = subsequentTrack
        
        let gapBeforeSubsequentTrack = PlaybackGap(3, .afterTrack)
        playlist.setGapsForTrack(subsequentTrack, gapBeforeSubsequentTrack, nil)
        XCTAssertEqual(playlist.getGapBeforeTrack(subsequentTrack), gapBeforeSubsequentTrack)
        
        // Publish a message for the delegate to process
        Messenger.publish(.player_trackPlaybackCompleted, payload: PlaybackSession.currentSession!)
        
        executeAfter(0.2) {
            
            // Message should have been processed ... track playback should have continued
            XCTAssertEqual(self.trackPlaybackCompletedChain.executionCount, 1)
            XCTAssertEqual(self.startPlaybackChain.executionCount, 2)
            
            // 0 + 3 = 3 seconds total delay
            self.assertWaitingTrack(subsequentTrack, 3)
        }
        
        executeAfter(3) {
            
            // Delay should be over, new track should be transcoding
            self.assertTranscodingTrack(subsequentTrack)
        }
        
        executeAfter(2) {
            
            // Prepare track and signal transcoding finished
            subsequentTrack.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            Messenger.publish(TranscodingFinishedNotification(track: subsequentTrack, success: true))
            
            usleep(500000)
            
            // Track should still be waiting and ready for playback when the delay ends
            XCTAssertTrue(subsequentTrack.lazyLoadingInfo.preparedForPlayback)
            self.assertPlayingTrack(subsequentTrack)
        }
    }
    
    //    func testTrackPlaybackCompleted_noSubsequentTrack_gapAfterCompletedTrack() {
    //    }
    //
    //    func testTrackPlaybackCompleted_noSubsequentTrack_gapBetweenTracks() {
    //    }
    //
    //    func testTrackPlaybackCompleted_noDelay_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBetweenTracks() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBetweenTracks_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_gapBetweenTracks() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapAfterCompletedTrack_gapBeforeSubsequentTrack_gapBetweenTracks_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_gapBetweenTracks() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_gapBetweenTracks_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapBeforeSubsequentTrack_trackNeedsTranscoding() {
    //    }
    //
    //    func testTrackPlaybackCompleted_gapBetweenTracks_trackNeedsTranscoding() {
    //    }
}
