//
//  DelayAndTranscoding_EndToEndTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class DelayAndTranscoding_EndToEndTests: PlaybackDelegateTests {
    
    // MARK: play() tests -----------------------------------------------------------------------------
    
    func testPlay_delayAndTranscoding_delayShorterThanTranscoding() {
        
        let track = createTrack("Enchantment", "wma", 180)
        doBeginPlaybackWithDelay(track, 2)
        
        assertWaitingTrack(track, 2)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, track)
        
        executeAfter(3) {
            
            // Gap has completed, now the track should be transcoding
            self.assertTranscodingTrack(track)
            
            // Prepare track and signal transcoding finished
            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            Messenger.publish(TranscodingFinishedNotification(track: track, success: true))
            
            usleep(500000)
            
            // Track should now be playing
            self.assertPlayingTrack(track)
        }
    }
    
    func testPlay_delayAndTranscoding_delayLongerThanTranscoding() {
        
        let track = createTrack("Odyssey", "wma", 180)
        doBeginPlaybackWithDelay(track, 4)
        
        assertWaitingTrack(track, 4)
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, track)
        
        executeAfter(1) {
            
            // Prepare track and signal transcoding finished
            track.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/TranscoderOutputFile.m4a"))
            Messenger.publish(TranscodingFinishedNotification(track: track, success: true))
            
            usleep(500000)
            
            // Track should still be waiting and ready for playback when the delay ends
            XCTAssertTrue(track.lazyLoadingInfo.preparedForPlayback)
            self.assertWaitingTrack(track, 4)
        }
        
        executeAfter(3.5) {
            self.assertPlayingTrack(track)
        }
    }
}
