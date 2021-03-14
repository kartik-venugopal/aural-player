import XCTest

class StopPlaybackChainTests: AuralTestCase, NotificationSubscriber {
    
    var chain: TestableStopPlaybackChain!
    
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    var sequencer: MockSequencer!
    var transcoder: MockTranscoder!
    var preferences: PlaybackPreferences!
    
    var profiles: PlaybackProfiles!
    
    var preTrackChangeMsgCount: Int = 0
    var preTrackChangeMsg_currentTrack: Track?
    var preTrackChangeMsg_currentState: PlaybackState?
    var preTrackChangeMsg_newTrack: Track?
    
    var trackTransitionMsgCount: Int = 0
    var trackTransitionMsg_currentTrack: Track?
    var trackTransitionMsg_currentState: PlaybackState?
    var trackTransitionMsg_newTrack: Track?

    override func setUp() {
        
        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(mockPlayerGraph, mockScheduler)
        sequencer = MockSequencer()
        transcoder = MockTranscoder()
        
        preferences = PlaybackPreferences([:])
        profiles = PlaybackProfiles()
        
        chain = TestableStopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
        
        Messenger.subscribe(self, .player_preTrackChange, self.preTrackChange(_:))
        Messenger.subscribe(self, .player_trackTransitioned, self.trackTransitioned(_:))
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        trackTransitionMsgCount.increment()
        
        trackTransitionMsg_currentTrack = notif.beginTrack
        trackTransitionMsg_currentState = notif.beginState
        trackTransitionMsg_newTrack = notif.endTrack
    }
    
    func preTrackChange(_ notif: PreTrackChangeNotification) {
        
        preTrackChangeMsgCount.increment()
        
        preTrackChangeMsg_currentTrack = notif.oldTrack
        preTrackChangeMsg_currentState = notif.oldState
        preTrackChangeMsg_newTrack = notif.newTrack
    }
    
    func testActions() {
        
        XCTAssertTrue(chain.actions[0] is SavePlaybackProfileAction)
        XCTAssertTrue(chain.actions[1] is CancelTranscodingAction)
        XCTAssertTrue(chain.actions[2] is HaltPlaybackAction)
        XCTAssertTrue(chain.actions[3] is EndPlaybackSequenceAction)
    }
    
    func testStop_noPlayingTrack() {
        
        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
        chain.execute(context)
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 0)
        
        assertTrackChange(nil, .noTrack)
    }
    
    func testStop_trackPlaying() {
        
        let playingTrack = createTrack("Silene", 420)
        playingTrack.prepareForPlayback()
        XCTAssertTrue(playingTrack.lazyLoadingInfo.preparedForPlayback)
        
        player.play(playingTrack, 0, nil)
        XCTAssertEqual(player.state, PlaybackState.playing)
        
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
        profiles.add(playingTrack, PlaybackProfile(playingTrack, 105.3242323))
        
        let context = PlaybackRequestContext(.playing, playingTrack, 203.34242434, nil, PlaybackParams.defaultParams())
        chain.execute(context)
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 1)
        assertTrackChange(playingTrack, .playing)
        
        XCTAssertEqual(profiles.get(playingTrack)!.lastPosition, context.currentSeekPosition)
    }
    
    func testStop_trackPaused() {
        
        let playingTrack = createTrack("Silene", 420)
        playingTrack.prepareForPlayback()
        XCTAssertTrue(playingTrack.lazyLoadingInfo.preparedForPlayback)
        
        player.play(playingTrack, 0, nil)
        player.pause()
        XCTAssertEqual(player.state, PlaybackState.paused)
        
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
        profiles.add(playingTrack, PlaybackProfile(playingTrack, 105.3242323))
        
        let context = PlaybackRequestContext(.paused, playingTrack, 203.34242434, nil, PlaybackParams.defaultParams())
        chain.execute(context)
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 1)
        assertTrackChange(playingTrack, .paused)
        
        XCTAssertEqual(profiles.get(playingTrack)!.lastPosition, context.currentSeekPosition)
    }
    
    func testStop_trackWaiting() {
        
        let waitingTrack = createTrack("Silene", 420)
        player.waiting()
        XCTAssertEqual(player.state, PlaybackState.waiting)
        
        let context = PlaybackRequestContext(.waiting, waitingTrack, 203.34242434, nil, PlaybackParams.defaultParams())
        chain.execute(context)
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 1)
        
        assertTrackChange(waitingTrack, .waiting)
    }
    
    func testStop_trackTranscoding() {
        
        let transcodingTrack = createTrack("Silene", 420)
        player.transcoding()
        XCTAssertEqual(player.state, PlaybackState.transcoding)
        
        let context = PlaybackRequestContext(.transcoding, transcodingTrack, 203.34242434, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 1)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, transcodingTrack)
        
        assertTrackChange(transcodingTrack, .transcoding)
    }
    
    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState) {
        
        XCTAssertEqual(preTrackChangeMsgCount, 1)
        XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
        XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
        XCTAssertEqual(preTrackChangeMsg_newTrack, nil)
        
        XCTAssertEqual(self.trackTransitionMsgCount, 1)
        XCTAssertEqual(self.trackTransitionMsg_currentTrack, currentTrack)
        XCTAssertEqual(self.trackTransitionMsg_currentState, currentState)
        XCTAssertEqual(self.trackTransitionMsg_newTrack, nil)
    }
}
