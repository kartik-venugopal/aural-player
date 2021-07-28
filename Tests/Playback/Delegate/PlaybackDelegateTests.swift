//
//  PlaybackDelegateTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests: AuralTestCase {

    var delegate: PlaybackDelegate!

    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!

    var sequencer: MockSequencer!
    var playlist: Playlist!
    var preferences: PlaybackPreferences!
    var trackReader: MockTrackReader!
    var controlsPreferences: GesturesControlsPreferences!

    var startPlaybackChain: TestableStartPlaybackChain!
    var stopPlaybackChain: TestableStopPlaybackChain!
    var trackPlaybackCompletedChain: TestableTrackPlaybackCompletedChain!

    var trackTransitionMessages: [TrackTransitionNotification] = []
    
    lazy var messenger = Messenger(for: self)

    override func setUp() {

        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(graph: mockPlayerGraph, avfScheduler: mockScheduler, ffmpegScheduler: mockScheduler)
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        sequencer = MockSequencer()
        
        controlsPreferences = GesturesControlsPreferences([:])
        preferences = PlaybackPreferences([:], controlsPreferences)
        
        trackReader = MockTrackReader()
        
        let profiles = PlaybackProfiles([])
        
        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences)
        
        stopPlaybackChain = TestableStopPlaybackChain(player, playlist, sequencer, profiles, preferences)
        trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)
        
        delegate = PlaybackDelegate(player, sequencer, profiles, preferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
        
        sequencer.reset()
        delegate.stop()
        _ = PlaybackSession.endCurrent()
        stopPlaybackChain.executionCount = 0

        XCTAssertNil(delegate.playingTrack)
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)

        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 0)

        trackTransitionMessages.removeAll()

        messenger.subscribe(to: .player_trackTransitioned, handler: self.trackTransitioned(_:))
    }

    override func tearDown() {
        
        messenger.unsubscribeFromAll()
        delegate.stopListeningForMessages()
        player.stopListeningForMessages()
        startPlaybackChain.stopListeningForMessages()
    }

    func verifyRequestContext_startPlaybackChain(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track, _ requestParams: PlaybackParams, _ cancelTranscoding: Bool) {

        XCTAssertEqual(startPlaybackChain.executedContext!.currentState, currentState)
        XCTAssertEqual(startPlaybackChain.executedContext!.currentTrack, currentTrack)
        XCTAssertEqual(startPlaybackChain.executedContext!.currentSeekPosition, currentSeekPosition, accuracy: 0.001)

        XCTAssertEqual(startPlaybackChain.executedContext!.requestedTrack, requestedTrack)

        XCTAssertEqual(startPlaybackChain.executedContext!.requestParams.interruptPlayback, requestParams.interruptPlayback)
        XCTAssertEqual(startPlaybackChain.executedContext!.requestParams.startPosition, requestParams.startPosition)
        XCTAssertEqual(startPlaybackChain.executedContext!.requestParams.endPosition, requestParams.endPosition)
    }

    func verifyRequestContext_stopPlaybackChain(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double) {

        XCTAssertEqual(stopPlaybackChain.executedContext!.currentState, currentState)
        XCTAssertEqual(stopPlaybackChain.executedContext!.currentTrack, currentTrack)
        XCTAssertEqual(stopPlaybackChain.executedContext!.currentSeekPosition, currentSeekPosition, accuracy: 0.001)

        XCTAssertNil(stopPlaybackChain.executedContext!.requestedTrack)

        let requestParams = PlaybackParams.defaultParams()

        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.interruptPlayback, requestParams.interruptPlayback)
        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.startPosition, requestParams.startPosition)
        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.endPosition, requestParams.endPosition)
    }

    func verifyRequestContext_trackPlaybackCompletedChain(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double) {

        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.currentState, currentState)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.currentTrack, currentTrack)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.currentSeekPosition, currentSeekPosition, accuracy: 0.001)

        let requestParams = PlaybackParams.defaultParams()

        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.interruptPlayback, requestParams.interruptPlayback)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.startPosition, requestParams.startPosition)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.endPosition, requestParams.endPosition)
    }

    func assertNoTrack() {

        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertNil(delegate.playingTrack)
    }

    func assertPlayingTrack(_ track: Track) {

        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertEqual(delegate.playingTrack, track)
    }

    func assertPausedTrack(_ track: Track) {

        XCTAssertEqual(delegate.state, PlaybackState.paused)
        XCTAssertEqual(delegate.playingTrack, track)
    }

    func assertTrackChange(_ oldTrack: Track?, _ oldState: PlaybackState, _ newTrack: Track?, _ totalMsgCount: Int = 1) {

        XCTAssertEqual(trackTransitionMessages.count, totalMsgCount)

        let trackTransitionMsg = trackTransitionMessages.last!
        XCTAssertEqual(trackTransitionMsg.beginTrack, oldTrack)
        XCTAssertEqual(trackTransitionMsg.beginState, oldState)
        XCTAssertEqual(trackTransitionMsg.endTrack, newTrack)
    }

    func doBeginPlayback(_ track: Track?) {

        sequencer.beginTrack = track

        // Begin playback
        delegate.togglePlayPause()

        XCTAssertEqual(sequencer.beginCallCount, 1)

        if let theTrack = track {

            assertPlayingTrack(theTrack)

            XCTAssertEqual(startPlaybackChain.executionCount, 1)
            verifyRequestContext_startPlaybackChain(.noTrack, nil, 0, theTrack, PlaybackParams.defaultParams(), false)

            self.assertTrackChange(nil, .noTrack, theTrack)

        } else {

            assertNoTrack()

            XCTAssertEqual(startPlaybackChain.executionCount, 0)

            XCTAssertEqual(self.trackTransitionMessages.count, 0)
        }
    }

    func doPausePlayback(_ track: Track) {

        let trackTransitionMsgCountBefore = trackTransitionMessages.count

        let startPlaybackChainExecCountBefore = startPlaybackChain.executionCount
        let stopPlaybackChainExecCountBefore = stopPlaybackChain.executionCount

        let sequencerBeginCallCountBefore = sequencer.beginCallCount

        let sequencerSubsequentCallCountBefore = sequencer.subsequentCallCount
        let sequencerPreviousCallCountBefore = sequencer.previousCallCount
        let sequencerNextCallCountBefore = sequencer.nextCallCount

        let sequencerSelectIndexCallCountBefore = sequencer.selectIndexCallCount
        let sequencerSelectTrackCallCountBefore = sequencer.selectTrackCallCount
        let sequencerSelectGroupCallCountBefore = sequencer.selectGroupCallCount

        delegate.togglePlayPause()
        assertPausedTrack(track)

        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainExecCountBefore)
        XCTAssertEqual(stopPlaybackChain.executionCount, stopPlaybackChainExecCountBefore)

        XCTAssertEqual(sequencer.beginCallCount, sequencerBeginCallCountBefore)

        XCTAssertEqual(sequencer.subsequentCallCount, sequencerSubsequentCallCountBefore)
        XCTAssertEqual(sequencer.previousCallCount, sequencerPreviousCallCountBefore)
        XCTAssertEqual(sequencer.nextCallCount, sequencerNextCallCountBefore)

        XCTAssertEqual(sequencer.selectIndexCallCount, sequencerSelectIndexCallCountBefore)
        XCTAssertEqual(sequencer.selectTrackCallCount, sequencerSelectTrackCallCountBefore)
        XCTAssertEqual(sequencer.selectGroupCallCount, sequencerSelectGroupCallCountBefore)

        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBefore)
    }

    func doResumePlayback(_ track: Track) {

        let trackTransitionMsgCountBefore = trackTransitionMessages.count

        let startPlaybackChainExecCountBefore = startPlaybackChain.executionCount
        let stopPlaybackChainExecCountBefore = stopPlaybackChain.executionCount

        let sequencerBeginCallCountBefore = sequencer.beginCallCount

        let sequencerSubsequentCallCountBefore = sequencer.subsequentCallCount
        let sequencerPreviousCallCountBefore = sequencer.previousCallCount
        let sequencerNextCallCountBefore = sequencer.nextCallCount

        let sequencerSelectIndexCallCountBefore = sequencer.selectIndexCallCount
        let sequencerSelectTrackCallCountBefore = sequencer.selectTrackCallCount
        let sequencerSelectGroupCallCountBefore = sequencer.selectGroupCallCount

        delegate.togglePlayPause()
        assertPlayingTrack(track)

        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainExecCountBefore)
        XCTAssertEqual(stopPlaybackChain.executionCount, stopPlaybackChainExecCountBefore)

        XCTAssertEqual(sequencer.beginCallCount, sequencerBeginCallCountBefore)

        XCTAssertEqual(sequencer.subsequentCallCount, sequencerSubsequentCallCountBefore)
        XCTAssertEqual(sequencer.previousCallCount, sequencerPreviousCallCountBefore)
        XCTAssertEqual(sequencer.nextCallCount, sequencerNextCallCountBefore)

        XCTAssertEqual(sequencer.selectIndexCallCount, sequencerSelectIndexCallCountBefore)
        XCTAssertEqual(sequencer.selectTrackCallCount, sequencerSelectTrackCallCountBefore)
        XCTAssertEqual(sequencer.selectGroupCallCount, sequencerSelectGroupCallCountBefore)

        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBefore)
    }

    private let lock = ExclusiveAccessSemaphore()
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {

        lock.executeAfterWait {
            trackTransitionMessages.append(notif)
        }
    }

    func setup_emptyPlaylist_noPlayingTrack() {

        playlist.clear()

        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertNil(delegate.playingTrack)
    }
}

extension PlaybackDelegate {
    
    func stopListeningForMessages() {
        messenger.unsubscribeFromAll()
    }
}

extension StartPlaybackChain {
    
    func stopListeningForMessages() {
        messenger.unsubscribeFromAll()
    }
}
