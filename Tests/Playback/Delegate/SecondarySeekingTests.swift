//
//  SecondarySeekingTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SecondarySeekingTests: PlaybackDelegateTests {
    
    // MARK: seekBackwardSecondary() tests ------------------------------------------------------------------------
    
    func testSeekBackwardSecondary_noPlayingTrack() {
        
        assertNoTrack()
        delegate.seekBackwardSecondary()
        
        assertNoTrack()
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }
    
    func testSeekBackwardSecondary_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.seekBackwardSecondary()
        
        assertWaitingTrack(track, 5)
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }
    
    func testSeekBackwardSecondary_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "ogg", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.seekBackwardSecondary()
        
        assertTranscodingTrack(track)
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }
    
    func testSeekBackwardSecondary_constantSeekLength() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
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
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekLength in seekLengths {
                    
                    delegate.play(track)
                    doSeekBackwardSecondary_constantSeekLength(track, startPosition, seekLength)
                }
            }
        }
    }
    
    private func doSeekBackwardSecondary_constantSeekLength(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .constant
        preferences.secondarySeekLengthConstant = seekLength
        
        delegate.seekBackwardSecondary()
        
        assertPlayingTrack(track, true)
        
        let expectedSeekPosition = currentPosition - Double(seekLength)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekBackwardSecondary_constantSeekLength_trackPaused() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
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
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekLength in seekLengths {
                    
                    delegate.play(track)
                    
                    delegate.togglePlayPause()
                    XCTAssertEqual(delegate.state, PlaybackState.paused)
                    
                    doSeekBackwardSecondary_constantSeekLength_trackPaused(track, startPosition, seekLength)
                }
            }
        }
    }
    
    private func doSeekBackwardSecondary_constantSeekLength_trackPaused(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .constant
        preferences.secondarySeekLengthConstant = seekLength
        
        delegate.seekBackwardSecondary()
        
        assertPausedTrack(track, true)
        
        let expectedSeekPosition = currentPosition - Double(seekLength)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekBackwardSecondary_trackDurationPercentage() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])
        
        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }
        
        for trackDuration in trackDurations {
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekPercentage in seekPercentages {
                    
                    delegate.play(track)
                    doSeekBackwardSecondary_trackDurationPercentage(track, startPosition, seekPercentage)
                }
            }
        }
    }
    
    private func doSeekBackwardSecondary_trackDurationPercentage(_ track: Track, _ currentPosition: Double, _ percentage: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .percentage
        preferences.secondarySeekLengthPercentage = percentage
        
        delegate.seekBackwardSecondary()
        
        assertPlayingTrack(track, true)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        
        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition - seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekBackwardSecondary_trackDurationPercentage_trackPaused() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])
        
        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }
        
        for trackDuration in trackDurations {
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekPercentage in seekPercentages {
                    
                    delegate.play(track)
                    
                    delegate.togglePlayPause()
                    XCTAssertEqual(delegate.state, PlaybackState.paused)
                    
                    doSeekBackwardSecondary_trackDurationPercentage_trackPaused(track, startPosition, seekPercentage)
                }
            }
        }
    }
    
    private func doSeekBackwardSecondary_trackDurationPercentage_trackPaused(_ track: Track, _ currentPosition: Double, _ percentage: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .percentage
        preferences.secondarySeekLengthPercentage = percentage
        
        delegate.seekBackwardSecondary()
        
        assertPausedTrack(track, true)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        
        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition - seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    // MARK: seekForwardSecondary() tests ------------------------------------------------------------------------
    
    func testSeekForwardSecondary_noPlayingTrack() {
        
        assertNoTrack()
        delegate.seekForwardSecondary()
        
        assertNoTrack()
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }
    
    func testSeekForwardSecondary_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.seekForwardSecondary()
        
        assertWaitingTrack(track, 5)
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }
    
    func testSeekForwardSecondary_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "ogg", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.seekForwardSecondary()
        
        assertTranscodingTrack(track)
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 0)
    }
    
    func testSeekForwardSecondary_constantSeekLength() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
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
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekLength in seekLengths {
                    
                    delegate.play(track)
                    doSeekForwardSecondary_constantSeekLength(track, startPosition, seekLength)
                }
            }
        }
    }
    
    private func doSeekForwardSecondary_constantSeekLength(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .constant
        preferences.secondarySeekLengthConstant = seekLength
        
        delegate.seekForwardSecondary()
        
        let expectedSeekPosition = currentPosition + Double(seekLength)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        let trackCompleted: Bool = expectedSeekPosition >= track.duration
        XCTAssertEqual(player.attemptSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))
        
        if !trackCompleted {
            assertPlayingTrack(track, true)
        }
    }
    
    func testSeekForwardSecondary_constantSeekLength_trackPaused() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
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
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekLength in seekLengths {
                    
                    delegate.play(track)
                    
                    delegate.togglePlayPause()
                    XCTAssertEqual(delegate.state, PlaybackState.paused)
                    
                    doSeekForwardSecondary_constantSeekLength_trackPaused(track, startPosition, seekLength)
                }
            }
        }
    }
    
    private func doSeekForwardSecondary_constantSeekLength_trackPaused(_ track: Track, _ currentPosition: Double, _ seekLength: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .constant
        preferences.secondarySeekLengthConstant = seekLength
        
        delegate.seekForwardSecondary()
        
        assertPausedTrack(track, true)
        
        let expectedSeekPosition = currentPosition + Double(seekLength)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekForwardSecondary_trackDurationPercentage() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])
        
        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }
        
        for trackDuration in trackDurations {
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekPercentage in seekPercentages {
                    
                    delegate.play(track)
                    doSeekForwardSecondary_trackDurationPercentage(track, startPosition, seekPercentage)
                }
            }
        }
    }
    
    private func doSeekForwardSecondary_trackDurationPercentage(_ track: Track, _ currentPosition: Double, _ percentage: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        
        preferences.secondarySeekLengthOption = .percentage
        preferences.secondarySeekLengthPercentage = percentage
        
        delegate.seekForwardSecondary()
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        
        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition + seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        let trackCompleted: Bool = expectedSeekPosition >= track.duration
        XCTAssertEqual(player.attemptSeekResult!.trackPlaybackCompleted, trackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore + (trackCompleted ? 1 : 0))
        
        if !trackCompleted {
            assertPlayingTrack(track, true)
        }
    }
    
    func testSeekForwardSecondary_trackDurationPercentage_trackPaused() {
        
        // Don't want notifications for this test
        Messenger.unsubscribe(self, .player_trackTransitioned)
        
        var trackDurations: Set<Double> = Set()
        for _ in 1...100 {
            trackDurations.insert(Double.random(in: 1...360000))   // 1 second to 100 hours
        }
        
        var seekPercentages: Set<Int> = Set([1, 2, 3, 5, 10, 25, 50, 100])
        
        for _ in 1...10 {
            seekPercentages.insert(Int.random(in: 1...100))
        }
        
        for trackDuration in trackDurations {
            
            let track = createTrack("Like a Virgin", trackDuration)
            
            var startPositions: Set<Double> = Set([0, trackDuration])
            for _ in 1...100 {
                startPositions.insert(Double.random(in: 0...trackDuration))
            }
            
            for startPosition in startPositions {
                
                for seekPercentage in seekPercentages {
                    
                    delegate.play(track)
                    
                    delegate.togglePlayPause()
                    XCTAssertEqual(delegate.state, PlaybackState.paused)
                    
                    doSeekForwardSecondary_trackDurationPercentage_trackPaused(track, startPosition, seekPercentage)
                }
            }
        }
    }
    
    private func doSeekForwardSecondary_trackDurationPercentage_trackPaused(_ track: Track, _ currentPosition: Double, _ percentage: Int) {
        
        let seekToTimeCallCountBefore = player.attemptSeekToTimeCallCount
        let trackCompletionCountBefore = trackPlaybackCompletedChain.executionCount
        
        mockScheduler.seekPosition = currentPosition
        preferences.secondarySeekLengthOption = .percentage
        preferences.secondarySeekLengthPercentage = percentage
        
        delegate.seekForwardSecondary()
        
        assertPausedTrack(track, true)
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, seekToTimeCallCountBefore + 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        
        let seekAmount = Double(percentage) * track.duration / 100.0
        let expectedSeekPosition = currentPosition + seekAmount
        XCTAssertEqual(player.attemptSeekToTime_time!, expectedSeekPosition, accuracy: 0.001)
        
        XCTAssertFalse(player.attemptSeekResult!.trackPlaybackCompleted)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, trackCompletionCountBefore)
    }
    
    func testSeekForwardSecondary_trackCompletion_noNewTrack() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        mockScheduler.seekPosition = track.duration - 0.235349534985
        preferences.secondarySeekLengthOption = .constant
        preferences.secondarySeekLengthConstant = 10
        
        // After the seek takes the first track to completion, this track should begin playing.
        sequencer.subsequentTrack = nil
        
        // Perform the seek
        delegate.seekForwardSecondary()
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!,
                       mockScheduler.seekPosition + Double(preferences.secondarySeekLengthConstant), accuracy: 0.001)
        
        // Verify track playback completion
        
        assertNoTrack()
        
        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        
        self.assertTrackChange(track, .playing, nil, 2)
    }
    
    func testSeekForwardSecondary_trackCompletion_newTrack() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        mockScheduler.seekPosition = track.duration - 0.235349534985
        preferences.secondarySeekLengthOption = .constant
        preferences.secondarySeekLengthConstant = 10
        
        // After the seek takes the first track to completion, this track should begin playing.
        let subsequentTrack = createTrack("Strangers by Night", 305.123986345)
        sequencer.subsequentTrack = subsequentTrack
        
        // Perform the seek
        delegate.seekForwardSecondary()
        
        XCTAssertEqual(player.attemptSeekToTimeCallCount, 1)
        XCTAssertEqual(player.attemptSeekToTime_track!, track)
        XCTAssertEqual(player.attemptSeekToTime_time!,
                       mockScheduler.seekPosition + Double(preferences.secondarySeekLengthConstant), accuracy: 0.001)
        
        // Verify track playback completion
        
        assertPlayingTrack(subsequentTrack)
        
        XCTAssertEqual(sequencer.subsequentCallCount, 1)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 1)
        XCTAssertEqual(startPlaybackChain.executionCount, 2)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        
        self.assertTrackChange(track, .playing, subsequentTrack, 2)
    }
}
