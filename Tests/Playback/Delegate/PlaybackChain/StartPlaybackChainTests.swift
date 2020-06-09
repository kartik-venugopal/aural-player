import XCTest

class StartPlaybackChainTests: AuralTestCase, MessageSubscriber, AsyncMessageSubscriber {
    
    var chain: TestableStartPlaybackChain!
    
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
    
    var trackTransitionMsgCount: Int = 0
    var trackTransitionMsg_currentTrack: Track?
    var trackTransitionMsg_currentState: PlaybackState?
    var trackTransitionMsg_newTrack: Track?
    
    var gapStartedMsgCount: Int = 0
    var gapStartedMsg_oldTrack: Track?
    var gapStartedMsg_newTrack: Track?
    var gapStartedMsg_endTime: Date?
    
    var transcodingStartedMsgCount: Int = 0
    var transcodingStartedMsg_oldTrack: Track?
    var transcodingStartedMsg_newTrack: Track?
    
    var trackNotPlayedMsgCount: Int = 0
    var trackNotPlayedMsg_oldTrack: Track?
    var trackNotPlayedMsg_error: InvalidTrackError?

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
        
        chain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
        
        SyncMessenger.subscribe(messageTypes: [.preTrackChangeNotification], subscriber: self)
        AsyncMessenger.subscribe([.trackTransition, .trackNotPlayed], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
    }
    
    override func tearDown() {
        
        SyncMessenger.unsubscribe(messageTypes: [.preTrackChangeNotification], subscriber: self)
        AsyncMessenger.unsubscribe([.trackTransition, .trackNotPlayed], subscriber: self)
        
        AsyncMessenger.unsubscribe([.transcodingFinished], subscriber: chain)
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
        
        if let trackTransitionMsg = message as? TrackTransitionAsyncMessage {
            
            if trackTransitionMsg.gapStarted {
                
                gapStartedMsgCount.increment()
                
                gapStartedMsg_oldTrack = trackTransitionMsg.beginTrack
                gapStartedMsg_endTime = trackTransitionMsg.gapEndTime
                gapStartedMsg_newTrack = trackTransitionMsg.endTrack
                
            } else if trackTransitionMsg.transcodingStarted {
                
                transcodingStartedMsgCount.increment()
                
                transcodingStartedMsg_oldTrack = trackTransitionMsg.beginTrack
                transcodingStartedMsg_newTrack = trackTransitionMsg.endTrack
                
            } else if trackTransitionMsg.playbackStarted {
            
                trackTransitionMsgCount.increment()
                
                trackTransitionMsg_currentTrack = trackTransitionMsg.beginTrack
                trackTransitionMsg_currentState = trackTransitionMsg.beginState
                trackTransitionMsg_newTrack = trackTransitionMsg.endTrack
            }
            
        } else if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
            
            trackNotPlayedMsgCount.increment()
            trackNotPlayedMsg_oldTrack = trackNotPlayedMsg.oldTrack
            trackNotPlayedMsg_error = trackNotPlayedMsg.error
            
            return
        }
    }
    
    func testStartPlayback_noRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        assertTrackNotPlayed(currentTrack, nil)
    }
    
    func testStartPlayback_requestedTrackInvalid() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420, isValid: false)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparationFailed)
        
        assertTrackNotPlayed(currentTrack, requestedTrack)
    }
    
    func testStartPlayback() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        assertTrackChange(currentTrack, .playing, requestedTrack)
    }
    
    func testStartPlayback_currentTrackIsTranscoding_transcodingCancelled() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, currentTrack)
        
        assertTrackChange(currentTrack, .transcoding, requestedTrack)
    }
    
    func testStartPlayback_currentTrackIsWaiting_oldContextInvalidated() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        
        let oldRequestParams = PlaybackParams.defaultParams().withDelay(3)
        let oldContext = PlaybackRequestContext(.noTrack, nil, 0, currentTrack, oldRequestParams)
        
        chain.execute(oldContext)
        
        XCTAssertEqual(oldContext.delay!, 3)
        XCTAssertEqual(player.state, .waiting)
        XCTAssertTrue(PlaybackRequestContext.isCurrent(oldContext))
        
        let requestedTrack = createTrack("Silene", 420)
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        // The old context should no longer be current
        XCTAssertFalse(PlaybackRequestContext.isCurrent(oldContext))
        
        assertTrackChange(currentTrack, .waiting, requestedTrack)
        
        // Wait for the old track's delay to transpire
        executeAfter(oldRequestParams.delay! + 1) {
            
            // Assert that the old context did not cause a track change
            XCTAssertEqual(self.trackTransitionMsgCount, 1)
        }
    }
    
    func testStartPlayback_currentTrackhasPlaybackProfile_profileSaved() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let oldProfile = PlaybackProfile(currentTrack, 125.324235346746)
        profiles.add(currentTrack, oldProfile)
        XCTAssertNotNil(profiles.get(currentTrack))
        
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
        let context = PlaybackRequestContext(.playing, currentTrack, 52.98743578, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        // Ensure profile was updated
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition)
        
        assertTrackChange(currentTrack, .playing, requestedTrack)
    }
    
    func testStartPlayback_currentTrackHasPlaybackProfile_profilePositionResetTo0() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let oldProfile = PlaybackProfile(currentTrack, 125.324235346746)
        profiles.add(currentTrack, oldProfile)
        XCTAssertNotNil(profiles.get(currentTrack))
        
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        // Ensure profile was reset to 0
        let newProfile = profiles.get(currentTrack)!
        XCTAssertEqual(newProfile.lastPosition, 0)
        
        assertTrackChange(currentTrack, .playing, requestedTrack)
    }
    
    func testStartPlayback_delayBeforeRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let requestParams = PlaybackParams.defaultParams().withDelay(3)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        chain.execute(context)

        XCTAssertEqual(context.delay!, requestParams.delay!)
        assertGapStarted(currentTrack, requestedTrack)
        
        justWait(context.delay!)
        assertTrackChange(requestedTrack, .waiting, requestedTrack)
    }
    
    func testStartPlayback_delayBeforeRequestedTrack_requestedTrackInvalid() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420, isValid: false)
        
        let requestParams = PlaybackParams.defaultParams().withDelay(3)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        chain.execute(context)
        
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparationFailed)

        justWait(requestParams.delay!)
        assertTrackNotPlayed(currentTrack, requestedTrack)
    }
    
    func testStartPlayback_gapBeforeRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        let gapBeforeRequestedTrack = PlaybackGap(3, .beforeTrack)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        chain.execute(context)

        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        assertGapStarted(currentTrack, requestedTrack)
        
        justWait(context.delay!)
        assertTrackChange(requestedTrack, .waiting, requestedTrack)
    }
    
    func testStartPlayback_requestedTrackNeedsTranscoding() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", "ogg", 420)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.needsTranscoding)
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparationFailed)
        
        assertTranscodingStarted(currentTrack, requestedTrack)
        
        // Simulate transcoding finished
        requestedTrack.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/AudioFile.m4a"))
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparedForPlayback)
        
        AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(requestedTrack, true))
        justWait(0.5)
        
        assertTrackChange(requestedTrack, .transcoding, requestedTrack)
    }
    
    func testStartPlayback_requestedTrackNeedsTranscoding_transcodingFailed() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", "ogg", 420)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.needsTranscoding)
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparationFailed)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, requestedTrack)
        
        XCTAssertEqual(player.state, .transcoding)
        
        // Simulate transcoding failed
        requestedTrack.lazyLoadingInfo.preparationFailed(NoAudioTracksError(requestedTrack))
        AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(requestedTrack, false))
        justWait(0.5)
        
        assertTrackNotPlayed(requestedTrack, requestedTrack)
    }
    
    private func assertTrackNotPlayed(_ oldTrack: Track, _ newTrack: Track?) {

        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackChangeMsgCount, 0)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackTransitionMsgCount, 0)
            
            XCTAssertEqual(self.trackNotPlayedMsgCount, 1)
            XCTAssertEqual(self.trackNotPlayedMsg_oldTrack, oldTrack)
            XCTAssertEqual(self.trackNotPlayedMsg_error!.track, newTrack)
        }
    }
    
    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState, _ newTrack: Track) {
        
        let trackChanged = currentTrack != newTrack
        
        XCTAssertEqual(preTrackChangeMsgCount, trackChanged ? 1 : 0)
        
        if trackChanged {
            
            XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
            XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
            XCTAssertEqual(preTrackChangeMsg_newTrack!, newTrack)
        }
        
        XCTAssertEqual(player.state, .playing)
        
        executeAfter(0.5) {
        
            XCTAssertEqual(self.trackTransitionMsgCount, 1)
            XCTAssertEqual(self.trackTransitionMsg_currentTrack, currentTrack)
            XCTAssertEqual(self.trackTransitionMsg_currentState, currentState)
            XCTAssertEqual(self.trackTransitionMsg_newTrack, newTrack)
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
    
    private func assertTranscodingStarted(_ oldTrack: Track?, _ newTrack: Track) {
        
        XCTAssertEqual(player.state, PlaybackState.transcoding)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, newTrack)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.transcodingStartedMsgCount, 1)
            XCTAssertEqual(self.transcodingStartedMsg_oldTrack, oldTrack)
            XCTAssertEqual(self.transcodingStartedMsg_newTrack!, newTrack)
        }
    }
    
    private func assertGapNotStarted() {
        
        executeAfter(0.5) {
            XCTAssertEqual(self.gapStartedMsgCount, 0)
        }
    }
}
