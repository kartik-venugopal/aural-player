import XCTest

class TrackPlaybackCompletedChainTests: AuralTestCase, MessageSubscriber, AsyncMessageSubscriber {
    
    var startPlaybackChain: TestableStartPlaybackChain!
    var stopPlaybackChain: TestableStopPlaybackChain!
    
    var chain: TrackPlaybackCompletedChain!
    
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    var playlist: TestablePlaylist!
    
    var sequencer: MockSequencer!
    var transcoder: MockTranscoder!
    var preferences: PlaybackPreferences!
    var profiles: PlaybackProfiles!
    
    var preTrackChangeMsgCount: Int = 0
    var preTrackChangeMsg_currentTrack: Track?
    var preTrackChangeMsg_currentState: PlaybackState?
    var preTrackChangeMsg_newTrack: Track?
    
    var trackChangeMsgCount: Int = 0
    var trackChangeMsg_currentTrack: Track?
    var trackChangeMsg_currentState: PlaybackState?
    var trackChangeMsg_newTrack: Track?
    
    var gapStartedMsgCount: Int = 0
    var gapStartedMsg_oldTrack: Track?
    var gapStartedMsg_newTrack: Track?
    var gapStartedMsg_endTime: Date?
    
    var trackNotPlayedMsgCount: Int = 0
    var trackNotPlayedMsg_oldTrack: Track?

    override func setUp() {
        
        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(mockPlayerGraph, mockScheduler)
        sequencer = MockSequencer()
        transcoder = MockTranscoder()
        
        preferences = PlaybackPreferences([:])
        profiles = PlaybackProfiles()
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists, .artist)
        let albumsPlaylist = GroupingPlaylist(.albums, .album)
        let genresPlaylist = GroupingPlaylist(.genres, .genre)
        
        playlist = TestablePlaylist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
        stopPlaybackChain = TestableStopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
        
        chain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer, playlist, profiles, preferences)
        
        SyncMessenger.subscribe(messageTypes: [.preTrackChangeNotification], subscriber: self)
        AsyncMessenger.subscribe([.trackChanged, .trackNotPlayed, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
    }
    
    override func tearDown() {
        
        SyncMessenger.unsubscribe(messageTypes: [.preTrackChangeNotification], subscriber: self)
        AsyncMessenger.unsubscribe([.trackChanged, .trackNotPlayed, .gapStarted], subscriber: self)
        
        AsyncMessenger.unsubscribe([.transcodingFinished], subscriber: startPlaybackChain)
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? PreTrackChangeNotification {
            
            preTrackChangeMsgCount.increment()
            
            preTrackChangeMsg_currentTrack = msg.oldTrack
            preTrackChangeMsg_currentState = msg.oldState
            preTrackChangeMsg_newTrack = msg.newTrack
            
            return
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackChangeMsg = message as? TrackChangedAsyncMessage {
            
            trackChangeMsgCount.increment()
            
            trackChangeMsg_currentTrack = trackChangeMsg.oldTrack
            trackChangeMsg_currentState = trackChangeMsg.oldState
            trackChangeMsg_newTrack = trackChangeMsg.newTrack
            
            return
            
        } else if let gapStartedMsg = message as? PlaybackGapStartedAsyncMessage {
            
            gapStartedMsgCount.increment()
            
            gapStartedMsg_oldTrack = gapStartedMsg.lastPlayedTrack
            gapStartedMsg_endTime = gapStartedMsg.gapEndTime
            gapStartedMsg_newTrack = gapStartedMsg.nextTrack
            
            return
            
        } else if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
            
            trackNotPlayedMsgCount.increment()
            trackNotPlayedMsg_oldTrack = trackNotPlayedMsg.oldTrack
            
            return
        }
    }
    
    func testTrackPlaybackCompleted_noSubsequentTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        sequencer.subsequentTrack = nil
        
        let oldProfile = PlaybackProfile(completedTrack, 125.324235346746)
        profiles.add(completedTrack, oldProfile)
        XCTAssertNotNil(profiles.get(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        XCTAssertNil(context.requestedTrack)
        
        chain.execute(context)
        
        // Ensure profile was reset to 0
        let newProfile = profiles.get(completedTrack)!
        XCTAssertEqual(newProfile.lastPosition, 0)
        
        assertTrackChange(completedTrack, .playing, nil)
    }
    
    func testTrackPlaybackCompleted_noSubsequentTrack_gapAfterCompletedTrack_noDelay() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        sequencer.subsequentTrack = nil
        
        playlist.setGapsForTrack(completedTrack, nil, PlaybackGap(3, .afterTrack))
        XCTAssertNotNil(playlist.getGapAfterTrack(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertNil(context.requestedTrack)
        
        // No delay (because there is no subsequent track)
        XCTAssertNil(context.delay)
        
        assertTrackChange(completedTrack, .playing, nil)
    }
    
    func testTrackPlaybackCompleted_noSubsequentTrack_gapBetweenTracks_noDelay() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        sequencer.subsequentTrack = nil
        
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 3
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertNil(context.requestedTrack)
        
        // No delay (because there is no subsequent track)
        XCTAssertNil(context.delay)
        
        assertTrackChange(completedTrack, .playing, nil)
    }
    
    func testTrackPlaybackCompleted_subsequentTrackInvalid() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420, isValid: false)
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        assertTrackNotPlayed(completedTrack)
    }
    
    func testTrackPlaybackCompleted_hasSubsequentTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        assertTrackChange(completedTrack, .playing, subsequentTrack)
    }
    
    func testTrackPlaybackCompleted_hasSubsequentTrack_hasPlaybackProfile_resetTo0() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let oldProfile = PlaybackProfile(completedTrack, 125.324235346746)
        profiles.add(completedTrack, oldProfile)
        XCTAssertNotNil(profiles.get(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        // Ensure profile was reset to 0
        let newProfile = profiles.get(completedTrack)!
        XCTAssertEqual(newProfile.lastPosition, 0)
        
        assertTrackChange(completedTrack, .playing, subsequentTrack)
    }
    
    func testTrackPlaybackCompleted_gapAfterCompletedTrack_hasSubsequentTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        playlist.setGapsForTrack(completedTrack, nil, PlaybackGap(3, .afterTrack))
        XCTAssertNotNil(playlist.getGapAfterTrack(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        XCTAssertEqual(context.delay!, playlist.getGapAfterTrack(completedTrack)!.duration)
        
        assertGapStarted(completedTrack, subsequentTrack)
        
        justWait(context.delay!)
        assertTrackChange(completedTrack, .waiting, subsequentTrack)
    }
    
    func testTrackPlaybackCompleted_gapAfterCompletedTrack_invalidSubsequentTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420, isValid: false)
        sequencer.subsequentTrack = subsequentTrack
        
        playlist.setGapsForTrack(completedTrack, nil, PlaybackGap(3, .afterTrack))
        XCTAssertNotNil(playlist.getGapAfterTrack(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        XCTAssertEqual(context.delay!, playlist.getGapAfterTrack(completedTrack)!.duration)
        
        assertGapNotStarted()
        assertTrackNotPlayed(completedTrack)
    }
    
    func testTrackPlaybackCompleted_gapBetweenTracks_hasSubsequentTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 3
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        XCTAssertEqual(context.delay!, Double(preferences.gapBetweenTracksDuration))
        
        assertGapStarted(completedTrack, subsequentTrack)
        
        justWait(context.delay!)
        assertTrackChange(completedTrack, .waiting, subsequentTrack)
    }
    
    func testTrackPlaybackCompleted_subsequentTrackNeedsTranscoding() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", "ogg", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        XCTAssertFalse(subsequentTrack.lazyLoadingInfo.preparedForPlayback)
        XCTAssertTrue(subsequentTrack.lazyLoadingInfo.needsTranscoding)
        XCTAssertFalse(subsequentTrack.lazyLoadingInfo.preparationFailed)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, subsequentTrack)
        
        XCTAssertEqual(player.state, .transcoding)
        
        // Simulate transcoding finished
        subsequentTrack.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/AudioFile.m4a"))
        AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(subsequentTrack, true))
        
        justWait(0.5)
        assertTrackChange(completedTrack, .playing, subsequentTrack)
    }
    
    func testTrackPlaybackCompleted_subsequentTrackNeedsTranscoding_transcodingFailed() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", "ogg", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        XCTAssertFalse(subsequentTrack.lazyLoadingInfo.preparedForPlayback)
        XCTAssertTrue(subsequentTrack.lazyLoadingInfo.needsTranscoding)
        XCTAssertFalse(subsequentTrack.lazyLoadingInfo.preparationFailed)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, subsequentTrack)
        
        XCTAssertEqual(player.state, .transcoding)
        
        // Simulate transcoding failed
        subsequentTrack.lazyLoadingInfo.preparationFailed(NoAudioTracksError(subsequentTrack))
        AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(subsequentTrack, false))
        
        justWait(0.5)
        assertTrackNotPlayed(completedTrack)
    }
    
    private func assertTrackNotPlayed(_ oldTrack: Track) {

        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackChangeMsgCount, 0)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackChangeMsgCount, 0)
            
            XCTAssertEqual(self.trackNotPlayedMsgCount, 1)
            XCTAssertEqual(self.trackNotPlayedMsg_oldTrack, oldTrack)
        }
    }
    
    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState, _ newTrack: Track?) {
        
        XCTAssertEqual(preTrackChangeMsgCount, 1)
        XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
        XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
        XCTAssertEqual(preTrackChangeMsg_newTrack, newTrack)
        
        XCTAssertEqual(player.state, newTrack == nil ? .noTrack : .playing)
        
        XCTAssertEqual(startPlaybackChain.executionCount, newTrack == nil ? 0 : 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, newTrack == nil ? 1 : 0)
        
        executeAfter(0.5) {
        
            XCTAssertEqual(self.trackChangeMsgCount, 1)
            XCTAssertEqual(self.trackChangeMsg_currentTrack, currentTrack)
            XCTAssertEqual(self.trackChangeMsg_currentState, currentState)
            XCTAssertEqual(self.trackChangeMsg_newTrack, newTrack)
        }
    }
    
    private func assertGapStarted(_ oldTrack: Track?, _ newTrack: Track) {
        
        XCTAssertEqual(player.state, PlaybackState.waiting)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.gapStartedMsgCount, 1)
            XCTAssertEqual(self.gapStartedMsg_oldTrack, oldTrack)
            XCTAssertEqual(self.gapStartedMsg_newTrack!, newTrack)
            XCTAssertEqual(self.gapStartedMsg_endTime!.compare(Date()), ComparisonResult.orderedDescending)
        }
    }
    
    private func assertGapNotStarted() {
        
        executeAfter(0.5) {
            XCTAssertEqual(self.gapStartedMsgCount, 0)
        }
    }
}
