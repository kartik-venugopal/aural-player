import XCTest

class StartPlaybackChainTests: AuralTestCase, NotificationSubscriber {
    
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
    
    var trackChangeMsgCount: Int = 0
    var trackChangeMsg_currentTrack: Track?
    var trackChangeMsg_currentState: PlaybackState?
    var trackChangeMsg_newTrack: Track?
    
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
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = TestablePlaylist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        chain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
        
        Messenger.subscribe(self, .player_preTrackChange, self.preTrackChange(_:))
        Messenger.subscribe(self, .player_trackTransitioned, self.trackTransitioned(_:))
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
        Messenger.unsubscribeAll(for: chain)
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            
            if notif.gapStarted {
                
                gapStarted(notif)
                
            } else if notif.transcodingStarted {
                
                transcodingStarted(notif)
                
            } else if notif.playbackStarted || notif.playbackEnded {
                
                trackChanged(notif)
            }
        })
    }
    
    func preTrackChange(_ notif: PreTrackChangeNotification) {
        
        preTrackChangeMsgCount.increment()
        
        preTrackChangeMsg_currentTrack = notif.oldTrack
        preTrackChangeMsg_currentState = notif.oldState
        preTrackChangeMsg_newTrack = notif.newTrack
    }
    
    func trackChanged(_ notif: TrackTransitionNotification) {
        
        trackChangeMsgCount.increment()
        
        trackChangeMsg_currentTrack = notif.beginTrack
        trackChangeMsg_newTrack = notif.endTrack
        trackChangeMsg_currentState = notif.beginState
    }
    
    func gapStarted(_ notif: TrackTransitionNotification) {
        
        gapStartedMsgCount.increment()
        
        gapStartedMsg_oldTrack = notif.beginTrack
        gapStartedMsg_endTime = notif.gapEndTime
        gapStartedMsg_newTrack = notif.endTrack
    }
    
    func transcodingStarted(_ notif: TrackTransitionNotification) {
        
        transcodingStartedMsgCount.increment()
        
        transcodingStartedMsg_oldTrack = notif.beginTrack
        transcodingStartedMsg_newTrack = notif.endTrack
    }
    
    func trackNotPlayed(_ notif: TrackNotPlayedNotification) {
        
        trackNotPlayedMsgCount.increment()
        trackNotPlayedMsg_oldTrack = notif.oldTrack
        trackNotPlayedMsg_error = notif.error
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
        
        assertTrackChange(currentTrack, .playing, requestedTrack, 1)
    }
    
    func testStartPlayback_currentTrackIsTranscoding_transcodingCancelled() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Silene", 420)
        
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, currentTrack)
        
        assertTrackChange(currentTrack, .transcoding, requestedTrack, 1)
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
        
        assertTrackChange(currentTrack, .waiting, requestedTrack, 1)
        
        // Wait for the old track's delay to transpire
        executeAfter(oldRequestParams.delay! + 0.5) {
            
            // Assert that the old context did not cause a track change
            XCTAssertEqual(self.trackChangeMsgCount, 1)
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
        
        assertTrackChange(currentTrack, .playing, requestedTrack, 1)
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
        
        assertTrackChange(currentTrack, .playing, requestedTrack, 1)
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
        assertTrackChange(requestedTrack, .waiting, requestedTrack, 1)
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
        assertTrackChange(requestedTrack, .waiting, requestedTrack, 1)
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
        
        Messenger.publish(TranscodingFinishedNotification(track: requestedTrack, success: true))
        justWait(0.2)
        
        assertTrackChange(requestedTrack, .transcoding, requestedTrack, 1)
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
        Messenger.publish(TranscodingFinishedNotification(track: requestedTrack, success: false))
        justWait(0.2)
        
        assertTrackNotPlayed(requestedTrack, requestedTrack)
    }
    
    private func assertTrackNotPlayed(_ oldTrack: Track, _ newTrack: Track?) {

        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackChangeMsgCount, 0)
        
        XCTAssertEqual(self.trackChangeMsgCount, 0)
        
        XCTAssertEqual(self.trackNotPlayedMsgCount, 1)
        XCTAssertEqual(self.trackNotPlayedMsg_oldTrack, oldTrack)
        XCTAssertEqual(self.trackNotPlayedMsg_error!.track, newTrack)
    }
    
    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState, _ newTrack: Track, _ expectedTransitionCount: Int) {
        
        let trackChanged = currentTrack != newTrack
        
        XCTAssertEqual(preTrackChangeMsgCount, trackChanged ? 1 : 0)
        
        if trackChanged {
            
            XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
            XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
            XCTAssertEqual(preTrackChangeMsg_newTrack!, newTrack)
        }
        
        XCTAssertEqual(self.player.state, .playing)
        
        XCTAssertEqual(self.trackChangeMsgCount, expectedTransitionCount)
        XCTAssertEqual(self.trackChangeMsg_currentTrack, currentTrack)
        XCTAssertEqual(self.trackChangeMsg_currentState, currentState)
        XCTAssertEqual(self.trackChangeMsg_newTrack, newTrack)
    }
    
    private func assertGapStarted(_ oldTrack: Track?, _ newTrack: Track) {
        
        XCTAssertEqual(player.state, PlaybackState.waiting)
    
        XCTAssertEqual(self.gapStartedMsgCount, 1)
        XCTAssertEqual(self.gapStartedMsg_oldTrack, oldTrack)
        XCTAssertEqual(self.gapStartedMsg_newTrack!, newTrack)
        XCTAssertEqual(self.gapStartedMsg_endTime!.compare(Date()), ComparisonResult.orderedDescending)
    }
    
    private func assertTranscodingStarted(_ oldTrack: Track?, _ newTrack: Track) {
        
        XCTAssertEqual(player.state, PlaybackState.transcoding)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, newTrack)
        
        XCTAssertEqual(self.transcodingStartedMsgCount, 1)
        XCTAssertEqual(self.transcodingStartedMsg_oldTrack, oldTrack)
        XCTAssertEqual(self.transcodingStartedMsg_newTrack!, newTrack)
    }
    
    private func assertGapNotStarted() {
        XCTAssertEqual(self.gapStartedMsgCount, 0)
    }
}
