//
//  MockScheduler.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class MockScheduler: PlaybackSchedulerProtocol {

    var playerNode: MockPlayerNode

    init(_ playerNode: MockPlayerNode) {
        self.playerNode = playerNode
    }

    // --------------------------------

    // Whether or not playTrack() has been called.
    var playTrackInvoked: Bool = false

    var playTrack_session: PlaybackSession?
    var playTrack_startPosition: Double?

    func playTrack(_ playbackSession: PlaybackSession, _ startPosition: Double) {

        playerNode.stop()

        playTrack_session = playbackSession
        playTrack_startPosition = startPosition

        playerNode.play()

        playTrackInvoked = true
    }

    // --------------------------------

    // Whether or not playLoop() has been called.
    var playLoopInvoked: Bool = false
    var playLoop_session: PlaybackSession?
    var playLoop_startTime: Double?
    var playLoop_beginPlayback: Bool?

    func playLoop(_ playbackSession: PlaybackSession, _ beginPlayback: Bool) {

        if let loop = playbackSession.loop {
            playLoop(playbackSession, loop.startTime, beginPlayback)
        }
    }

    func playLoop(_ playbackSession: PlaybackSession, _ playbackStartTime: Double, _ beginPlayback: Bool) {

        playerNode.stop()

        playLoop_session = playbackSession
        playLoop_startTime = playbackStartTime
        playLoop_beginPlayback = beginPlayback

        if beginPlayback {
            playerNode.play()
        }

        playLoopInvoked = true
    }

    // --------------------------------

    // Whether or not endLoop() has been called.
    var endLoopInvoked: Bool = false
    var endLoop_session: PlaybackSession?
    var endLoop_loopEndTime: Double?

    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double, _ beginPlayback: Bool) {

        endLoop_session = session
        endLoop_loopEndTime = loopEndTime

        endLoopInvoked = true
    }

    // --------------------------------

    // Whether or not seekToTime() has been called.
    var seekToTimeInvoked: Bool = false
    var seekToTime_session: PlaybackSession?
    var seekToTime_time: Double?
    var seekToTime_beginPlayback: Bool?

    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double, _ beginPlayback: Bool) {

        playerNode.stop()

        seekToTime_session = playbackSession
        seekToTime_time = seconds
        seekToTime_beginPlayback = beginPlayback

        if beginPlayback {
            playerNode.play()
        }

        seekToTimeInvoked = true
    }

    var paused: Bool = false
    var resumed: Bool = false
    var stopped: Bool = false

    func pause() {

        playerNode.pause()
        paused = true
    }

    func resume() {

        playerNode.play()
        resumed = true
    }

    func stop() {

        playerNode.stop()
        stopped = true
    }

    // -----------------------------------
    
    func reset() {

        playTrack_session = nil
        playTrack_startPosition = nil

        playLoop_session = nil
        playLoop_startTime = nil
        playLoop_beginPlayback = nil

        endLoop_session = nil
        endLoop_loopEndTime = nil

        seekToTime_session = nil
        seekToTime_time = nil
        seekToTime_beginPlayback = nil

        paused = false
        resumed = false
        stopped = false

        playTrackInvoked = false
        playLoopInvoked = false
        endLoopInvoked = false
        seekToTimeInvoked = false

        playerNode.resetMock()
    }
}
