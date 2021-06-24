//
//  AuralPlayerNodeTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest
import AVFoundation

class AuralPlayerNodeTests: XCTestCase {
    
    private var playerNode: TestableAuralPlayerNode = TestableAuralPlayerNode(useLegacyAPI: false)
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path"))

    override func setUp() {

        playerNode.resetMock()
        playerNode.useLegacyAPI = false
    }
    
    private func initTrack(_ duration: Double, _ sampleRate: Double) {
        
        let format: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let audioFile: AVAudioFile = MockAVAudioFile(format)
        
        track.setDuration(duration)
        
        track.playbackInfo = PlaybackInfo()
        track.playbackInfo?.audioFile = audioFile
        track.playbackInfo?.frames = AVAudioFramePosition.fromTrackTime(duration, sampleRate)
        track.playbackInfo?.sampleRate = sampleRate
    }

    func testSeekPosition_playing_startedAt0() {
        doTestSeekPosition(0, 12.97537, 44100)
    }
    
    func testSeekPosition_playing_notStartedAt0() {
        doTestSeekPosition(39.61113, 12.97537, 44100)
    }
    
    func testSeekPosition_paused() {
        
        let cachedSeekPosn = 45.6789193
        playerNode.cachedSeekPosn = cachedSeekPosn
        
        playerNode.sampleTime = nil
        playerNode.sampleRate = nil
        
        // When the player node is not playing, the seek position should be the last computed (i.e. cached) seek position.
        XCTAssertEqual(playerNode.seekPosition, cachedSeekPosn, accuracy: 0.001)
    }
    
    /*
        startPos:           The seek position (in seconds) at which the playerNode's sampleTime was reset to 0.
        trackTimePlayed:    The amount of track time (in seconds) that the playerNode has played after being reset at startPos.
        sampleRate:         Sample rate of the track being played.
     */
    private func doTestSeekPosition(_ startPos: Double,_ trackTimePlayed: Double, _ sampleRate: Double) {
        
        playerNode.startFrame = AVAudioFramePosition.fromTrackTime(startPos, sampleRate)
        playerNode.sampleRate = sampleRate
        playerNode.sampleTime = AVAudioFramePosition.fromTrackTime(trackTimePlayed, sampleRate)
        
        XCTAssertEqual(playerNode.seekPosition, startPos + trackTimePlayed, accuracy: 0.001)
    }
    
    // MARK: scheduleSegment(session) tests ------------------------------------------------------------------------------------------------------------
    // NOTE - These tests also exercise computeSegment() so there is no need to test it separately.
    
    func testScheduleSegmentWithSession_startTimeOnly_noPlaybackInfo() {

        // If no playback info is present within the track, no scheduling should take place.
        track.playbackInfo = nil
        
        let session = PlaybackSession.start(track)
        let segment = playerNode.scheduleSegment(session, {(PlaybackSession) -> Void in }, 0)

        // A nil segment means no scheduling took place
        XCTAssertNil(segment)
        
        XCTAssertEqual(playerNode.scheduleSegment_callCount, 0)
        XCTAssertNil(playerNode.scheduleSegment_startFrame)
        XCTAssertNil(playerNode.scheduleSegment_frameCount)
    }
    
    func testScheduleSegmentWithSession_startTimeOnly_validPlaybackInfo_0startTime() {
        
        doScheduleSegmentWithSession(300, 44100, 0, nil, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 0, nil, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 0, nil, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 0, nil, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startTimeOnly_validPlaybackInfo_arbitraryStartTime() {
        
        doScheduleSegmentWithSession(300, 44100, 299.987773, nil, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 0.1296324932, nil, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 3.1545357, nil, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 27.34536436907, nil, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startTimeOnly_validPlaybackInfo_startAtTrackEnd() {
        
        doScheduleSegmentWithSession(300, 44100, 300, nil, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 60, nil, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 3.54645, nil, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 59.324253322, nil, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startTimeOnly_validPlaybackInfo_startSlightlyPastTrackEnd() {
        
        doScheduleSegmentWithSession(300, 44100, 300.0023345345, nil, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 60.0134234, nil, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 3.546575, nil, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 59.325253667, nil, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_startAt0() {
        
        doScheduleSegmentWithSession(300, 44100, 0, 25, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 0, 59, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 0, 2.78943534, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 0, 57.7777666, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_startAndEndAt0() {
        
        doScheduleSegmentWithSession(300, 44100, 0, 0, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 0, 0, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 0, 0, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 0, 0, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_fullLengthOfFile() {
        
        doScheduleSegmentWithSession(300, 44100, 0, 300, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 0, 60, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 0, 3.54645, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 0, 59.324253322, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_arbitraryStartAndEndTimes() {
        
        doScheduleSegmentWithSession(300, 44100, 298.987773, 299.023423423, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 0.1296324932, 55.23432423, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 1.1545357, 2.74636, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 27.34536436907, 52.253636552, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_endAtTrackEnd() {
        
        doScheduleSegmentWithSession(300, 44100, 25.23423423, 300, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 17.64532336456, 60, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 1.112233447, 3.54645, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 26.435435345, 59.324253322, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_startAndEndAtTrackEnd() {
        
        doScheduleSegmentWithSession(300, 44100, 300, 300, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 60, 60, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 3.54645, 3.54645, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 59.324253322, 59.324253322, nil, 4)
    }
    
    func testScheduleSegmentWithSession_startAndEndTimes_validPlaybackInfo_endSlightlyPastTrackEnd() {
        
        doScheduleSegmentWithSession(300, 44100, 25, 300.0023345345, nil, 1)
        doScheduleSegmentWithSession(60, 48000, 32.234234, 60.0134234, nil, 2)
        doScheduleSegmentWithSession(3.54645, 96000, 1.73458394, 3.546575, nil, 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 18.234234, 59.325253667, nil, 4)
    }
    
    func testScheduleSegmentWithSession_withValidFirstFrame() {
        
        doScheduleSegmentWithSession(300, 44100, 25, nil, AVAudioFramePosition.fromTrackTime(25, 44100), 1)
        doScheduleSegmentWithSession(60, 48000, 32.234234, nil, AVAudioFramePosition.fromTrackTime(32.234234, 48000), 2)
        doScheduleSegmentWithSession(3.54645, 96000, 1.73458394, nil, AVAudioFramePosition.fromTrackTime(1.73458394, 96000), 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 18.234234, nil, AVAudioFramePosition.fromTrackTime(18.234234, 192000), 4)
    }
    
    func testScheduleSegmentWithSession_withInvalidFirstFrame() {
        
        doScheduleSegmentWithSession(300, 44100, 300, nil, AVAudioFramePosition.fromTrackTime(300.123234, 44100), 1)
        doScheduleSegmentWithSession(60, 48000, 60, nil, AVAudioFramePosition.fromTrackTime(60.00123234, 48000), 2)
        doScheduleSegmentWithSession(3.54645, 96000, 3.54645, nil, AVAudioFramePosition.fromTrackTime(3.56565656, 96000), 3)
        doScheduleSegmentWithSession(59.324253322, 192000, 59.324253322, nil, AVAudioFramePosition.fromTrackTime(59.33333, 192000), 4)
    }
    
    private func doScheduleSegmentWithSession(_ trackDuration: Double, _ sampleRate: Double, _ startTime: Double, _ endTime: Double?, _ firstFrame: AVAudioFramePosition?, _ expectedCallCount: Int) {
        
        // Set up the track with valid playback info (duration of 5 minutes and a sample rate of 44100 Hz).
        initTrack(trackDuration, sampleRate)

        let session = PlaybackSession.start(track)
        let segment = playerNode.scheduleSegment(session, {(PlaybackSession) -> Void in }, startTime, endTime, firstFrame)

        // A nil segment means no scheduling took place.
        XCTAssertNotNil(segment)
        
        if let theSegment = segment {
            
            XCTAssertEqual(playerNode.scheduleSegment_callCount, expectedCallCount)
            XCTAssertEqual(theSegment.session, session)
            
            if let totalFrameCount = track.playbackInfo?.frames {
                
                let lastFrameInFile = totalFrameCount - 1
                let expectedFirstFrame = firstFrame ?? AVAudioFramePosition.fromTrackTime(startTime, sampleRate)
                
                // Verify first frame
                if expectedFirstFrame < lastFrameInFile {
                    
                    // Normal scenario - first frame has not gone past the end of the file.
                
                    XCTAssertEqual(playerNode.scheduleSegment_startFrame, expectedFirstFrame)
                    XCTAssertEqual(theSegment.firstFrame, expectedFirstFrame)
                    
                } else {
                    
                    // Abnormal scenario - first frame has gone past the end of the file. A correction (minimum frames) should have been applied by the playerNode.
                    // In such a case, it is sufficient to ensure that the first frame scheduled is not past the end of the file.
                    
                    XCTAssertLessThanOrEqual(playerNode.scheduleSegment_startFrame!, lastFrameInFile)
                    XCTAssertLessThanOrEqual(theSegment.firstFrame, lastFrameInFile)
                }
                
                // Verify last frame
                if let theEndTime = endTime {
                    
                    // End time specified.
                    let expectedLastFrame = AVAudioFramePosition.fromTrackTime(theEndTime, sampleRate)
                    
                    if expectedLastFrame > lastFrameInFile {
                        
                        // Expect a correction.
                        XCTAssertLessThanOrEqual(playerNode.scheduleSegment_lastFrame!, lastFrameInFile)
                        XCTAssertLessThanOrEqual(theSegment.lastFrame, lastFrameInFile)
                        
                    } else {
                        
                        // Normal scenario - last frame has not gone past the end of the file.
                        // Expect the exact computed value.
                        XCTAssertEqual(theSegment.lastFrame, expectedLastFrame)
                    }
                    
                } else {
                    
                    // No end time specified, last frame must be last frame in file.
                    XCTAssertEqual(theSegment.lastFrame, lastFrameInFile)
                }
                
                // Verify frame count
                XCTAssertEqual(playerNode.scheduleSegment_frameCount, AVAudioFrameCount(theSegment.lastFrame - theSegment.firstFrame + 1))
                XCTAssertEqual(theSegment.frameCount, AVAudioFrameCount(theSegment.lastFrame - theSegment.firstFrame + 1))
            }
            
            // Verify start time.
            if let theFirstFrame = firstFrame {
            
                // Exact first frame specified, start time was computed.
                XCTAssertEqual(theSegment.startTime, theFirstFrame.toTrackTime(sampleRate), accuracy: 0.001)
                XCTAssertEqual(theSegment.startTime, theFirstFrame.toTrackTime(sampleRate), accuracy: 0.001)
                
            } else {
                
                // No first frame specified, use specified start time.
                XCTAssertEqual(theSegment.startTime, startTime, accuracy: 0.001)
                XCTAssertEqual(theSegment.startTime, startTime, accuracy: 0.001)
            }
            
            // Verify endTime
            if let theEndTime = endTime {
                
                // End time was specified.
                XCTAssertEqual(theSegment.endTime, theEndTime, accuracy: 0.001)
                
            } else {
                
                // End time was not specified. End of track implied.
                XCTAssertEqual(theSegment.endTime, trackDuration, accuracy: 0.001)
            }
            
            XCTAssertEqual(playerNode.scheduleSegment_audioFile, track.playbackInfo?.audioFile)
            XCTAssertEqual(theSegment.playingFile, track.playbackInfo?.audioFile)
        }
    }
    
    // MARK: scheduleSegment(segment) tests ------------------------------------------------------------------------------------------------------------
    
    func testScheduleSegmentWithSegment_immediatePlayback_startTimeOnly() {
        doScheduleSegmentWithSegment(300, 44100, 25.113455399857, nil, true, 1)
    }
    
    func testScheduleSegmentWithSegment_immediatePlayback_startAndEndTimes() {
        doScheduleSegmentWithSegment(300, 44100, 25.934798234986, 51.232353469, true, 1)
    }
    
    func testScheduleSegmentWithSegment_notImmediatePlayback_startTimeOnly() {
        doScheduleSegmentWithSegment(300, 44100, 25.2479457, nil, false, 1)
    }
    
    func testScheduleSegmentWithSegment_notImmediatePlayback_startAndEndTimes() {
        doScheduleSegmentWithSegment(300, 44100, 25.2473453, 297.2344569, false, 1)
    }
    
    func testScheduleSegmentWithSegment_immediatePlayback_startTimeOnly_useLegacyAPI() {
        doScheduleSegmentWithSegment(300, 44100, 25.113455399857, nil, true, 1, true)
    }
    
    func testScheduleSegmentWithSegment_immediatePlayback_startAndEndTimes_useLegacyAPI() {
        doScheduleSegmentWithSegment(300, 44100, 25.934798234986, 51.232353469, true, 1, true)
    }
    
    func testScheduleSegmentWithSegment_notImmediatePlayback_startTimeOnly_useLegacyAPI() {
        doScheduleSegmentWithSegment(300, 44100, 25.2479457, nil, false, 1, true)
    }
    
    func testScheduleSegmentWithSegment_notImmediatePlayback_startAndEndTimes_useLegacyAPI() {
        doScheduleSegmentWithSegment(300, 44100, 25.2473453, 297.2344569, false, 1, true)
    }
    
    private func doScheduleSegmentWithSegment(_ trackDuration: Double, _ sampleRate: Double, _ startTime: Double, _ endTime: Double?, _ immediatePlayback: Bool, _ expectedCallCount: Int, _ useLegacyAPI: Bool = false) {

        // Set up the track with valid playback info (duration of 5 minutes and a sample rate of 44100 Hz).
        initTrack(trackDuration, sampleRate)
        playerNode.useLegacyAPI = useLegacyAPI
        
        let nodeStartFrameBeforeScheduling: AVAudioFramePosition = playerNode.startFrame
        let nodeCachedSeekPosnBeforeScheduling: Double = playerNode.cachedSeekPosn

        let session = PlaybackSession.start(track)

        if let segment = playerNode.computeSegment(session, startTime, endTime) {
            
            playerNode.scheduleSegment(segment, {(PlaybackSession) -> Void in }, immediatePlayback)
            
            if immediatePlayback {
             
                XCTAssertEqual(playerNode.startFrame, segment.firstFrame)
                XCTAssertEqual(playerNode.cachedSeekPosn, segment.startTime)
                
            } else {
                
                XCTAssertEqual(playerNode.startFrame, nodeStartFrameBeforeScheduling)
                XCTAssertEqual(playerNode.cachedSeekPosn, nodeCachedSeekPosnBeforeScheduling)
            }
            
            XCTAssertEqual(segment.session, session)
            
            XCTAssertEqual(segment.startTime, startTime, accuracy: 0.001)
            XCTAssertEqual(segment.endTime, endTime ?? trackDuration, accuracy: 0.001)
            
            XCTAssertEqual(playerNode.scheduleSegment_audioFile, track.playbackInfo?.audioFile)
            XCTAssertEqual(segment.playingFile, track.playbackInfo?.audioFile)
            
            XCTAssertEqual(playerNode.scheduleSegment_callCount, expectedCallCount)
            XCTAssertEqual(playerNode.scheduleSegment_legacyAPI_callCount, useLegacyAPI ? expectedCallCount : 0)
            
            XCTAssertEqual(playerNode.scheduleSegment_startFrame, segment.firstFrame)
            XCTAssertEqual(playerNode.scheduleSegment_lastFrame, segment.lastFrame)
            XCTAssertEqual(playerNode.scheduleSegment_frameCount, segment.frameCount)
        }
    }
}
