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

class PlaybackDelegateTests: AuralTestCase, NotificationSubscriber {
    
    var delegate: PlaybackDelegate!
    
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    var sequencer: MockSequencer!
    var playlist: Playlist!
    var transcoder: MockTranscoder!
    var preferences: PlaybackPreferences!
    var controlsPreferences: ControlsPreferences!
    
    var startPlaybackChain: TestableStartPlaybackChain!
    var stopPlaybackChain: TestableStopPlaybackChain!
    var trackPlaybackCompletedChain: TestableTrackPlaybackCompletedChain!
    
    var trackTransitionMessages: [TrackTransitionNotification] = []
    var gapStartedMessages: [TrackTransitionNotification] = []
    var transcodingStartedMessages: [TrackTransitionNotification] = []
    
    override func setUp() {
        
        if delegate == nil {
            
            mockPlayerGraph = MockPlayerGraph()
            mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
            mockScheduler = MockScheduler(mockPlayerNode)
            
            player = TestablePlayer(mockPlayerGraph, mockScheduler)
            
            let flatPlaylist = FlatPlaylist()
            let artistsPlaylist = GroupingPlaylist(.artists)
            let albumsPlaylist = GroupingPlaylist(.albums)
            let genresPlaylist = GroupingPlaylist(.genres)
            
            playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
            sequencer = MockSequencer()
            
            transcoder = MockTranscoder()
            controlsPreferences = ControlsPreferences([:])
            preferences = PlaybackPreferences([:], controlsPreferences)
            
            let profiles = PlaybackProfiles()
            
            startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
            stopPlaybackChain = TestableStopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
            trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer, playlist, preferences)
            
            delegate = PlaybackDelegate(player, playlist, sequencer, profiles, preferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
        }
        
        sequencer.reset()
        delegate.stop()
        _ = PlaybackSession.endCurrent()
        stopPlaybackChain.executionCount = 0
        
        XCTAssertNil(delegate.currentTrack)
        XCTAssertNil(delegate.playingTrack)
        XCTAssertNil(delegate.waitingTrack)
        XCTAssertNil(delegate.transcodingTrack)
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 0)
        
        trackTransitionMessages.removeAll()

        Messenger.subscribe(self, .player_trackTransitioned, self.trackTransitioned(_:))
    }
    
    override func tearDown() {
        
        Messenger.unsubscribeAll(for: self)
        Messenger.unsubscribeAll(for: delegate)
        Messenger.unsubscribeAll(for: startPlaybackChain)
    }
    
    func verifyRequestContext_startPlaybackChain(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track, _ requestParams: PlaybackParams, _ cancelTranscoding: Bool) {
        
        XCTAssertEqual(startPlaybackChain.executedContext!.currentState, currentState)
        XCTAssertEqual(startPlaybackChain.executedContext!.currentTrack, currentTrack)
        XCTAssertEqual(startPlaybackChain.executedContext!.currentSeekPosition, currentSeekPosition, accuracy: 0.001)
        
        XCTAssertEqual(startPlaybackChain.executedContext!.requestedTrack, requestedTrack)

        XCTAssertEqual(startPlaybackChain.executedContext!.requestParams.interruptPlayback, requestParams.interruptPlayback)
        XCTAssertEqual(startPlaybackChain.executedContext!.requestParams.allowDelay, requestParams.allowDelay)
        XCTAssertEqual(startPlaybackChain.executedContext!.requestParams.delay, requestParams.delay)
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
        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.allowDelay, requestParams.allowDelay)
        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.delay, requestParams.delay)
        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.startPosition, requestParams.startPosition)
        XCTAssertEqual(stopPlaybackChain.executedContext!.requestParams.endPosition, requestParams.endPosition)
    }
    
    func verifyRequestContext_trackPlaybackCompletedChain(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double) {
        
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.currentState, currentState)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.currentTrack, currentTrack)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.currentSeekPosition, currentSeekPosition, accuracy: 0.001)

        let requestParams = PlaybackParams.defaultParams()

        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.interruptPlayback, requestParams.interruptPlayback)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.allowDelay, requestParams.allowDelay)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.delay, requestParams.delay)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.startPosition, requestParams.startPosition)
        XCTAssertEqual(trackPlaybackCompletedChain.executedContext!.requestParams.endPosition, requestParams.endPosition)
    }
    
    func assertNoTrack() {
        
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertAllNil(delegate.currentTrack, delegate.playingTrack, delegate.waitingTrack, delegate.transcodingTrack)
    }
    
    func assertPlayingTrack(_ track: Track, _ skipNilChecks: Bool = false) {
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.playingTrack, track)
        
        if !skipNilChecks {
            XCTAssertAllNil(delegate.waitingTrack, delegate.transcodingTrack)
        }
    }
    
    func assertPausedTrack(_ track: Track, _ skipNilChecks: Bool = false) {
        
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.playingTrack, track)
        
        if !skipNilChecks {
            XCTAssertAllNil(delegate.waitingTrack, delegate.transcodingTrack)
        }
    }
    
    func assertWaitingTrack(_ track: Track, _ delay: Double? = nil) {
        
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.waitingTrack, track)
        
        XCTAssertAllNil(delegate.playingTrack, delegate.transcodingTrack)
        
        if let theDelay = delay {
            XCTAssertEqual(startPlaybackChain.executedContext!.delay!, theDelay, accuracy: 0.001)
        } else {
            XCTAssertNotNil(startPlaybackChain.executedContext!.delay)
        }
    }
    
    func assertTranscodingTrack(_ track: Track) {
        
        XCTAssertEqual(delegate.state, PlaybackState.transcoding)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.transcodingTrack, track)
        
        XCTAssertAllNil(delegate.playingTrack, delegate.waitingTrack)
    }
    
    func assertTrackChange(_ oldTrack: Track?, _ oldState: PlaybackState, _ newTrack: Track?, _ totalMsgCount: Int = 1) {
        
        XCTAssertEqual(trackTransitionMessages.count, totalMsgCount)

        let trackTransitionMsg = trackTransitionMessages.last!
        XCTAssertEqual(trackTransitionMsg.beginTrack, oldTrack)
        XCTAssertEqual(trackTransitionMsg.beginState, oldState)
        XCTAssertEqual(trackTransitionMsg.endTrack, newTrack)
    }
    
    func assertGapStarted(_ lastPlayedTrack: Track?, _ nextTrack: Track, _ totalMsgCount: Int = 1) {
        
        XCTAssertEqual(self.gapStartedMessages.count, totalMsgCount)

        let gapStartedMsg = self.gapStartedMessages.last!

        XCTAssertEqual(gapStartedMsg.beginTrack, lastPlayedTrack)
        XCTAssertEqual(gapStartedMsg.endTrack, nextTrack)

        // Assert that the gap end time is in the future (i.e. > now)
        XCTAssertEqual(gapStartedMsg.gapEndTime!.compare(Date()), ComparisonResult.orderedDescending)
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
    
    func doBeginPlaybackWithDelay(_ track: Track, _ delay: Double) {
        
        // Begin playback
        let params = PlaybackParams.defaultParams().withDelay(delay)
        delegate.play(track, params)
        assertWaitingTrack(track, delay)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        verifyRequestContext_startPlaybackChain(.waiting, track, 0, track, params, true)
            
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
        self.assertGapStarted(nil, track)
    }
    
    func doBeginPlayback_trackNeedsTranscoding(_ track: Track) {
        
        XCTAssertFalse(track.playbackNativelySupported)
        
        transcoder.transcodeImmediately_readyForPlayback = false
        transcoder.transcodeImmediately_failed = false
        
        // Begin playback
        delegate.play(track)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        verifyRequestContext_startPlaybackChain(.transcoding, track, 0, track, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, track)
        
        XCTAssertEqual(self.trackTransitionMessages.count, 0)
        XCTAssertEqual(self.gapStartedMessages.count, 0)
        XCTAssertEqual(self.transcodingStartedMessages.count, 1)
    }
    
    func doPausePlayback(_ track: Track) {
        
        let trackTransitionMsgCountBefore = trackTransitionMessages.count
        let gapStartedMsgCountBefore = gapStartedMessages.count
        
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
        XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBefore)
    }
    
    func doResumePlayback(_ track: Track) {
        
        let trackTransitionMsgCountBefore = trackTransitionMessages.count
        let gapStartedMsgCountBefore = gapStartedMessages.count
        
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
        XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBefore)
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            
            if notif.gapStarted {
                gapStartedMessages.append(notif)
                
            } else if notif.transcodingStarted {
                transcodingStartedMessages.append(notif)
                
            } else if notif.playbackStarted || notif.playbackEnded {
                trackTransitionMessages.append(notif)
            }
        })
    }
    
    func setup_emptyPlaylist_noPlayingTrack() {
        
        playlist.clear()
        
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertNil(delegate.playingTrack)
        XCTAssertNil(delegate.waitingTrack)
    }
    
    let artists: [String] = ["Conjure One", "Grimes", "Madonna", "Pink Floyd", "Dire Straits", "Ace of Base", "Delerium", "Blue Stone", "Jaia", "Paul Van Dyk"]
    
    let albums: [String] = ["Exilarch", "Halfaxa", "Vogue", "The Wall", "Brothers in Arms", "The Sign", "Music Box Opera", "Messages", "Mai Mai", "Reflections"]
    
    let genres: [String] = ["Electronica", "Pop", "Rock", "Dance", "International", "Jazz", "Ambient", "House", "Trance", "Techno", "Psybient", "PsyTrance", "Classical", "Opera"]
    
    func randomArtist() -> String {
        return artists[Int.random(in: 0..<artists.count)]
    }
    
    func randomAlbum() -> String {
        return albums[Int.random(in: 0..<albums.count)]
    }
    
    func randomGenre() -> String {
        return genres[Int.random(in: 0..<genres.count)]
    }
}
