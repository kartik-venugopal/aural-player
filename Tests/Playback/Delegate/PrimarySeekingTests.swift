//
//  PrimarySeekingTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PrimarySeekingTests: PlaybackDelegateTests {

    // MARK: seekBackward() tests ------------------------------------------------------------------------

    func testSeekBackward_noPlayingTrack() {

        assertNoTrack()
        delegate.seekBackward()

        assertNoTrack()
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }

    func testSeekBackward_constantSeekLength() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekLengths: Set<Int> = Set([1, 2, 3, 5, 10, 15, 30, 45, 60])  // 1 second to 1 minute

        for _ in 1...5 {
            seekLengths.insert(.random(in: 61...600))   // 1 minute to 10 minutes
        }

        for _ in 1...3 {
            seekLengths.insert(.random(in: 600...3600))   // 10 minutes to 1 hour
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(.random(in: 0...trackDuration))
            }

            for (startPosition, seekLength) in zip(startPositions, seekLengths) {
                
                delegate.play(track)
                doSeekBackward_constantSeekLength(track, startPosition, seekLength)
            }
        }
    }

    private func doSeekBackward_constantSeekLength(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .constant
        preferences.primarySeekLengthConstant = seekLength

        delegate.seekBackward()

        assertPlayingTrack(track)

        let expectedSeekPosition = currentPosition - Double(seekLength)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekBackward_constantSeekLength_trackPaused() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekLengths: Set<Int> = Set([1, 2, 3, 5, 10, 15, 30, 45, 60])  // 1 second to 1 minute

        for _ in 1...5 {
            seekLengths.insert(.random(in: 61...600))   // 1 minute to 10 minutes
        }

        for _ in 1...3 {
            seekLengths.insert(.random(in: 600...3600))   // 10 minutes to 1 hour
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekLength) in zip(startPositions, seekLengths) {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekBackward_constantSeekLength_trackPaused(track, startPosition, seekLength)
            }
        }
    }

    private func doSeekBackward_constantSeekLength_trackPaused(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .constant
        preferences.primarySeekLengthConstant = seekLength

        delegate.seekBackward()

        assertPausedTrack(track)

        let expectedSeekPosition = currentPosition - Double(seekLength)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekBackward_trackDurationPercentage() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])

        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekPercentage) in zip(startPositions, seekPercentages) {
                
                delegate.play(track)
                doSeekBackward_trackDurationPercentage(track, startPosition, seekPercentage)
            }
        }
    }

    private func doSeekBackward_trackDurationPercentage(_ track: Track, _ currentPosition: Double, _ percentage: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .percentage
        preferences.primarySeekLengthPercentage = percentage

        delegate.seekBackward()

        assertPlayingTrack(track)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)

        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition - seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekBackward_trackDurationPercentage_trackPaused() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])

        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekPercentage) in zip(startPositions, seekPercentages) {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekBackward_trackDurationPercentage_trackPaused(track, startPosition, seekPercentage)
            }
        }
    }

    private func doSeekBackward_trackDurationPercentage_trackPaused(_ track: Track, _ currentPosition: Double, _ percentage: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .percentage
        preferences.primarySeekLengthPercentage = percentage

        delegate.seekBackward()

        assertPausedTrack(track)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)

        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition - seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekBackward_continuousActionMode() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, sensitivity) in zip(startPositions, ScrollSensitivity.allCases) {
                
                delegate.play(track)
                doSeekBackward_continuousActionMode(track, startPosition, sensitivity)
            }
        }
    }

    private func doSeekBackward_continuousActionMode(_ track: Track, _ currentPosition: Double, _ sensitivity: ScrollSensitivity) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition
        controlsPreferences.seekSensitivity = sensitivity

        delegate.seekBackward(.continuous)

        assertPlayingTrack(track)

        let expectedSeekPosition = currentPosition - preferences.seekLength_continuous

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekBackward_continuousActionMode_trackPaused() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, sensitivity) in zip(startPositions, ScrollSensitivity.allCases) {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekBackward_continuousActionMode_trackPaused(track, startPosition, sensitivity)
            }
        }
    }

    private func doSeekBackward_continuousActionMode_trackPaused(_ track: Track, _ currentPosition: Double, _ sensitivity: ScrollSensitivity) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition
        controlsPreferences.seekSensitivity = sensitivity

        delegate.seekBackward(.continuous)

        assertPausedTrack(track)

        let expectedSeekPosition = currentPosition - preferences.seekLength_continuous

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    // MARK: seekForward() tests ------------------------------------------------------------------------

    func testSeekForward_noPlayingTrack() {

        assertNoTrack()
        delegate.seekForward()

        assertNoTrack()
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }

    func testSeekForward_constantSeekLength() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekLengths: Set<Int> = Set([1, 2, 3, 5, 10, 15, 30, 45, 60])  // 1 second to 1 minute

        for _ in 1...5 {
            seekLengths.insert(Int.random(in: 61...600))   // 1 minute to 10 minutes
        }

        for _ in 1...3 {
            seekLengths.insert(Int.random(in: 600...3600))   // 10 minutes to 1 hour
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekLength) in zip(startPositions, seekLengths) {
                
                delegate.play(track)
                doSeekForward_constantSeekLength(track, startPosition, seekLength)
            }
        }
    }

    private func doSeekForward_constantSeekLength(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .constant
        preferences.primarySeekLengthConstant = seekLength

        delegate.seekForward()

        let expectedSeekPosition = currentPosition + Double(seekLength)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        let trackCompleted: Bool = expectedSeekPosition >= track.duration
        XCTAssertEqual(player.attemptSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))

        if !trackCompleted {
            assertPlayingTrack(track)
        }
    }

    func testSeekForward_constantSeekLength_trackPaused() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekLengths: Set<Int> = Set([1, 2, 3, 5, 10, 15, 30, 45, 60])  // 1 second to 1 minute

        for _ in 1...5 {
            seekLengths.insert(Int.random(in: 61...600))   // 1 minute to 10 minutes
        }

        for _ in 1...3 {
            seekLengths.insert(Int.random(in: 600...3600))   // 10 minutes to 1 hour
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekLength) in zip(startPositions, seekLengths) {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekForward_constantSeekLength_trackPaused(track, startPosition, seekLength)
            }
        }
    }

    private func doSeekForward_constantSeekLength_trackPaused(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .constant
        preferences.primarySeekLengthConstant = seekLength

        delegate.seekForward()

        assertPausedTrack(track)

        let expectedSeekPosition = currentPosition + Double(seekLength)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekForward_trackDurationPercentage() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])

        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekPercentage) in zip(startPositions, seekPercentages) {
                
                delegate.play(track)
                doSeekForward_trackDurationPercentage(track, startPosition, seekPercentage)
            }
        }
    }

    private func doSeekForward_trackDurationPercentage(_ track: Track, _ currentPosition: Double, _ percentage: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .percentage
        preferences.primarySeekLengthPercentage = percentage

        delegate.seekForward()

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)

        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition + seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        let trackCompleted: Bool = expectedSeekPosition >= track.duration
        XCTAssertEqual(player.attemptSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))

        if !trackCompleted {
            assertPlayingTrack(track)
        }
    }

    func testSeekForward_trackDurationPercentage_trackPaused() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])

        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, seekPercentage) in zip(startPositions, seekPercentages) {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekForward_trackDurationPercentage_trackPaused(track, startPosition, seekPercentage)
            }
        }
    }

    private func doSeekForward_trackDurationPercentage_trackPaused(_ track: Track, _ currentPosition: Double, _ percentage: Int) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition

        preferences.primarySeekLengthOption = .percentage
        preferences.primarySeekLengthPercentage = percentage

        delegate.seekForward()

        assertPausedTrack(track)

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)

        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition + seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekForward_continuousActionMode() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, sensitivity) in zip(startPositions, ScrollSensitivity.allCases) {
                
                delegate.play(track)
                doSeekForward_continuousActionMode(track, startPosition, sensitivity)
            }
        }
    }

    private func doSeekForward_continuousActionMode(_ track: Track, _ currentPosition: Double, _ sensitivity: ScrollSensitivity) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition
        controlsPreferences.seekSensitivity = sensitivity

        delegate.seekForward(.continuous)

        let expectedSeekPosition = currentPosition + preferences.seekLength_continuous

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        let trackCompleted: Bool = expectedSeekPosition >= track.duration
        XCTAssertEqual(player.attemptSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))

        if !trackCompleted {
            assertPlayingTrack(track)
        }
    }

    func testSeekForward_continuousActionMode_trackPaused() {

        // Don't want notifications for this test
        messenger.unsubscribe(from: .player_trackTransitioned)

        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }

        for trackDuration in trackDurations {

            let track = createTrack(title: "Like a Virgin", duration: trackDuration)

            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }

            for (startPosition, sensitivity) in zip(startPositions, ScrollSensitivity.allCases) {
                
                delegate.play(track)
                
                delegate.togglePlayPause()
                XCTAssertEqual(delegate.state, PlaybackState.paused)
                
                doSeekForward_continuousActionMode_trackPaused(track, startPosition, sensitivity)
            }
        }
    }

    private func doSeekForward_continuousActionMode_trackPaused(_ track: Track, _ currentPosition: Double, _ sensitivity: ScrollSensitivity) {

        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount

        mockPlayerNode._seekPosition = currentPosition
        controlsPreferences.seekSensitivity = sensitivity

        delegate.seekForward(.continuous)

        assertPausedTrack(track)

        let expectedSeekPosition = currentPosition + preferences.seekLength_continuous

        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)

        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }

    func testSeekForward_trackCompletion_noNewTrack() {

        let track = createTrack(title: "Like a Virgin", duration: 249.99887766)
        doBeginPlayback(track)

        mockPlayerNode._seekPosition = track.duration - 0.235349534985
        preferences.primarySeekLengthOption = .constant
        preferences.primarySeekLengthConstant = 10

        // After the seek takes the first track to completion, playback should end.
        sequencer.subsequentTrack = nil

        // Perform the seek
        delegate.seekForward()

        XCTAssertEqual(player.attemptSeekToTimeCallCount, 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!,
                       mockPlayerNode._seekPosition + Double(preferences.primarySeekLengthConstant), accuracy: 0.001)

        // Verify track playback completion

        assertNoTrack()

        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        self.assertTrackChange(track, .playing, nil, 2)
    }

    func testSeekForward_trackCompletion_newTrack() {

        let track = createTrack(title: "Like a Virgin", duration: 249.99887766)
        doBeginPlayback(track)

        mockPlayerNode._seekPosition = track.duration - 0.235349534985
        preferences.primarySeekLengthOption = .constant
        preferences.primarySeekLengthConstant = 10

        // After the seek takes the first track to completion, this track should begin playing.
        let subsequentTrack = createTrack(title: "Strangers by Night", duration: 305.123986345)
        sequencer.subsequentTrack = subsequentTrack

        // Perform the seek
        delegate.seekForward()

        XCTAssertEqual(player.attemptSeekToTimeCallCount, 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!,
                       mockPlayerNode._seekPosition + Double(preferences.primarySeekLengthConstant), accuracy: 0.001)

        // Verify track playback completion

        assertPlayingTrack(subsequentTrack)

        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)

        self.assertTrackChange(track, .playing, subsequentTrack, 2)
    }
}
