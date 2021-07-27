//
//  TestablePlayer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TestablePlayer: Player {

    var playCallCount: Int = 0
    var play_track: Track?
    var play_startPosition: Double?
    var play_endPosition: Double?

    override func play(_ track: Track, _ startPosition: Double, _ endPosition: Double?) {

        playCallCount.increment()

        play_track = track
        play_startPosition = startPosition
        play_endPosition = endPosition

        super.play(track, startPosition, endPosition)
    }

    var attemptSeekToTimeCallCount: Int = 0
    var attemptSeekToTime_track: Track?
    var attemptSeekToTime_time: Double?

    var attemptSeekResult: PlayerSeekResult?

    override func attemptSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {

        attemptSeekToTimeCallCount.increment()
        attemptSeekToTime_track = track
        attemptSeekToTime_time = time

        attemptSeekResult = super.attemptSeekToTime(track, time)
        return attemptSeekResult!
    }

    var forceSeekToTimeCallCount: Int = 0
    var forceSeekToTime_track: Track?
    var forceSeekToTime_time: Double?

    var forceSeekResult: PlayerSeekResult?

    override func forceSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {

        forceSeekToTimeCallCount.increment()
        forceSeekToTime_track = track
        forceSeekToTime_time = time

        forceSeekResult = super.forceSeekToTime(track, time)
        return forceSeekResult!
    }

    var toggleLoopCallCount: Int = 0
    var toggleLoopResult: PlaybackLoop?

    override func toggleLoop() -> PlaybackLoop? {

        toggleLoopCallCount.increment()
        toggleLoopResult = super.toggleLoop()
        return toggleLoopResult
    }

    var defineLoopCallCount: Int = 0
    var defineLoop_startTime: Double?
    var defineLoop_endTime: Double?

    override func defineLoop(_ loopStartPosition: Double, _ loopEndPosition: Double, _ isChapterLoop: Bool) {

        defineLoopCallCount.increment()
        defineLoop_startTime = loopStartPosition
        defineLoop_endTime = loopEndPosition

        super.defineLoop(loopStartPosition, loopEndPosition)
    }

    var stopCallCount: Int = 0

    override func stop() {

        stopCallCount.increment()
        super.stop()
    }

    func reset() {

        attemptSeekToTimeCallCount = 0
        attemptSeekToTime_track = nil
        attemptSeekToTime_time = nil
        attemptSeekResult = nil

        forceSeekToTimeCallCount = 0
        forceSeekToTime_track = nil
        forceSeekToTime_time = nil
        forceSeekResult = nil

        toggleLoopCallCount = 0
        toggleLoopResult = nil

        defineLoopCallCount = 0
        defineLoop_startTime = nil
        defineLoop_endTime = nil

        stopCallCount = 0
    }
}
