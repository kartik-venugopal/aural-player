//
//  TrackPlaybackCompletedChainTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class TrackPlaybackCompletedChainTests: AuralTestCase, NotificationSubscriber {
    
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
    
    var trackTransitionMsgCount: Int = 0
    var trackTransitionMsg_currentTrack: Track?
    var trackTransitionMsg_currentState: PlaybackState?
    var trackTransitionMsg_newTrack: Track?
    
    var gapStartedMsgCount: Int = 0
    var gapStartedMsg_oldTrack: Track?
    var gapStartedMsg_newTrack: Track?
    var gapStartedMsg_endTime: Date?
    
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
        
        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
        stopPlaybackChain = TestableStopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
        
        chain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer, playlist, preferences)
        
        Messenger.subscribe(self, .player_preTrackChange, self.preTrackChange(_:))
        Messenger.subscribe(self, .player_trackTransitioned, self.trackTransitioned(_:))
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
        Messenger.unsubscribeAll(for: startPlaybackChain)
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        if notif.gapStarted {
            
            gapStartedMsgCount.increment()
            
            gapStartedMsg_oldTrack = notif.beginTrack
            gapStartedMsg_endTime = notif.gapEndTime
            gapStartedMsg_newTrack = notif.endTrack
            
        } else if notif.playbackStarted || notif.playbackEnded {
            
            trackTransitionMsgCount.increment()
            
            trackTransitionMsg_currentTrack = notif.beginTrack
            trackTransitionMsg_currentState = notif.beginState
            trackTransitionMsg_newTrack = notif.endTrack
        }
    }
    
    func preTrackChange(_ notif: PreTrackChangeNotification) {
        
        preTrackChangeMsgCount.increment()
        
        preTrackChangeMsg_currentTrack = notif.oldTrack
        preTrackChangeMsg_currentState = notif.oldState
        preTrackChangeMsg_newTrack = notif.newTrack
    }
    
    func trackNotPlayed(_ notif: TrackNotPlayedNotification) {
        
        trackNotPlayedMsgCount.increment()
        trackNotPlayedMsg_oldTrack = notif.oldTrack
        trackNotPlayedMsg_error = notif.error
    }
    
    func testTrackPlaybackCompleted_noSubsequentTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        sequencer.subsequentTrack = nil
        
        let oldProfile = PlaybackProfile(completedTrack, 125.324235346746)
        profiles.add(completedTrack, oldProfile)
        XCTAssertNotNil(profiles.get(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
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
        
        assertTrackNotPlayed(completedTrack, subsequentTrack)
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
    
    func testTrackPlaybackCompleted_hasSubsequentTrack_completedTrackHasPlaybackProfile_resetTo0() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Silene", 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let oldProfile = PlaybackProfile(completedTrack, 125.324235346746)
        profiles.add(completedTrack, oldProfile)
        XCTAssertNotNil(profiles.get(completedTrack))
        
        preferences.rememberLastPosition = true
        preferences.rememberLastPositionOption = .individualTracks
        
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
        assertTrackChange(subsequentTrack, .waiting, subsequentTrack)
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
        assertTrackNotPlayed(completedTrack, subsequentTrack)
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
        assertTrackChange(subsequentTrack, .waiting, subsequentTrack)
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
        Messenger.publish(TranscodingFinishedNotification(track: subsequentTrack, success: true))
        justWait(0.2)
        
        assertTrackChange(subsequentTrack, .transcoding, subsequentTrack)
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
        Messenger.publish(TranscodingFinishedNotification(track: subsequentTrack, success: false))
        justWait(0.2)
        
        assertTrackNotPlayed(subsequentTrack, subsequentTrack)
    }
    
    private func assertTrackNotPlayed(_ oldTrack: Track, _ newTrack: Track) {

        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackChangeMsgCount, 0)
        
        XCTAssertEqual(self.trackTransitionMsgCount, 0)
        
        XCTAssertEqual(self.trackNotPlayedMsgCount, 1)
        XCTAssertEqual(self.trackNotPlayedMsg_oldTrack, oldTrack)
        XCTAssertEqual(self.trackNotPlayedMsg_error!.track, newTrack)
    }
    
    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState, _ newTrack: Track?) {
        
        let trackChanged = currentTrack != newTrack
        
        XCTAssertEqual(preTrackChangeMsgCount, trackChanged ? 1 : 0)
        
        if trackChanged {
            
            XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
            XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
            XCTAssertEqual(preTrackChangeMsg_newTrack, newTrack)
        }
        
        XCTAssertEqual(player.state, newTrack == nil ? .noTrack : .playing)
        
        XCTAssertEqual(startPlaybackChain.executionCount, newTrack == nil ? 0 : 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, newTrack == nil ? 1 : 0)
        
        XCTAssertEqual(self.trackTransitionMsgCount, 1)
        XCTAssertEqual(self.trackTransitionMsg_currentTrack, currentTrack)
        XCTAssertEqual(self.trackTransitionMsg_currentState, currentState)
        XCTAssertEqual(self.trackTransitionMsg_newTrack, newTrack)
    }
    
    private func assertGapStarted(_ oldTrack: Track?, _ newTrack: Track) {
        
        XCTAssertEqual(player.state, PlaybackState.waiting)
        
        XCTAssertEqual(self.gapStartedMsgCount, 1)
        XCTAssertEqual(self.gapStartedMsg_oldTrack, oldTrack)
        XCTAssertEqual(self.gapStartedMsg_newTrack!, newTrack)
        XCTAssertEqual(self.gapStartedMsg_endTime!.compare(Date()), ComparisonResult.orderedDescending)
    }
    
    private func assertGapNotStarted() {
        XCTAssertEqual(self.gapStartedMsgCount, 0)
    }
}
