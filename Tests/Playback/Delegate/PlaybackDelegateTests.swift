import XCTest

class PlaybackDelegateTests: AuralTestCase, AsyncMessageSubscriber {
    
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
    
    var trackChangeMessages: [TrackChangedAsyncMessage] = []
    var gapStartedMessages: [PlaybackGapStartedAsyncMessage] = []
    
    override func setUp() {
        
        if delegate == nil {
            
            mockPlayerGraph = MockPlayerGraph()
            mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
            mockScheduler = MockScheduler(mockPlayerNode)
            
            player = TestablePlayer(mockPlayerGraph, mockScheduler)
            
            let flatPlaylist = FlatPlaylist()
            let artistsPlaylist = GroupingPlaylist(.artists, .artist)
            let albumsPlaylist = GroupingPlaylist(.albums, .album)
            let genresPlaylist = GroupingPlaylist(.genres, .genre)
            
            playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
            sequencer = MockSequencer()
            
            transcoder = MockTranscoder()
            controlsPreferences = ControlsPreferences([:])
            preferences = PlaybackPreferences([:], controlsPreferences)
            
            delegate = PlaybackDelegate([], player, sequencer, playlist, transcoder, preferences)
            
            startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, delegate.profiles, preferences)
            stopPlaybackChain = TestableStopPlaybackChain(player, sequencer, transcoder, delegate.profiles, preferences)
            trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer, playlist, delegate.profiles, preferences)
            
            delegate.startPlaybackChain = startPlaybackChain
            delegate.stopPlaybackChain = stopPlaybackChain
            delegate.trackPlaybackCompletedChain = trackPlaybackCompletedChain
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
        
        trackChangeMessages.removeAll()
        gapStartedMessages.removeAll()
        
        AsyncMessenger.subscribe([.trackChanged, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
    }
    
    override func tearDown() {
        
        // Prevent test case objects from receiving each other's messages.
        AsyncMessenger.unsubscribe([.trackChanged, .gapStarted], subscriber: self)
        AsyncMessenger.unsubscribe([.playbackCompleted, .transcodingFinished], subscriber: delegate)
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
            
        XCTAssertFalse(PlaybackGapContext.hasGaps())
    }
    
    func assertPausedTrack(_ track: Track, _ skipNilChecks: Bool = false) {
        
        XCTAssertEqual(delegate.state, PlaybackState.paused)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.playingTrack, track)
        
        if !skipNilChecks {
            XCTAssertAllNil(delegate.waitingTrack, delegate.transcodingTrack)
        }
    }
    
    func assertWaitingTrack(_ track: Track) {
        
        XCTAssertEqual(delegate.state, PlaybackState.waiting)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.waitingTrack, track)
        
        XCTAssertAllNil(delegate.playingTrack, delegate.transcodingTrack)
        
        XCTAssertTrue(PlaybackGapContext.hasGaps())
    }
    
    func assertTranscodingTrack(_ track: Track) {
        
        XCTAssertEqual(delegate.state, PlaybackState.transcoding)
        
        XCTAssertEqual(delegate.currentTrack, track)
        XCTAssertEqual(delegate.transcodingTrack, track)
        
        XCTAssertAllNil(delegate.playingTrack, delegate.waitingTrack)
        XCTAssertFalse(PlaybackGapContext.hasGaps())
    }
    
    func assertTrackChange(_ oldTrack: Track?, _ oldState: PlaybackState, _ newTrack: Track?, _ totalMsgCount: Int = 1) {
        
        XCTAssertEqual(trackChangeMessages.count, totalMsgCount)
        
        let trackChangeMsg = trackChangeMessages.last!
        XCTAssertEqual(trackChangeMsg.oldTrack, oldTrack)
        XCTAssertEqual(trackChangeMsg.oldState, oldState)
        XCTAssertEqual(trackChangeMsg.newTrack, newTrack)
    }
    
    func assertGapStarted(_ lastPlayedTrack: Track?, _ nextTrack: Track, _ totalMsgCount: Int = 1) {
        
        XCTAssertEqual(self.gapStartedMessages.count, totalMsgCount)
        
        let gapStartedMsg = self.gapStartedMessages.last!
        
        XCTAssertEqual(gapStartedMsg.lastPlayedTrack, lastPlayedTrack)
        XCTAssertEqual(gapStartedMsg.nextTrack, nextTrack)
        
        // Assert that the gap end time is in the future (i.e. > now)
        XCTAssertEqual(gapStartedMsg.gapEndTime.compare(Date()), ComparisonResult.orderedDescending)
        
        XCTAssertTrue(PlaybackGapContext.hasGaps())
    }
    
    func doBeginPlayback(_ track: Track?) {
        
        sequencer.beginTrack = track
        
        // Begin playback
        delegate.togglePlayPause()
        
        XCTAssertEqual(sequencer.beginCallCount, 1)
        
        if let theTrack = track {
        
            assertPlayingTrack(theTrack)
            
            XCTAssertEqual(startPlaybackChain.executionCount, 1)
            
            executeAfter(0.5) {
                self.assertTrackChange(nil, .noTrack, theTrack)
            }
            
        } else {
            
            assertNoTrack()
            
            XCTAssertEqual(startPlaybackChain.executionCount, 0)
            
            executeAfter(0.5) {
                XCTAssertEqual(self.trackChangeMessages.count, 0)
            }
        }
    }
    
    func doBeginPlaybackWithDelay(_ track: Track, _ delay: Double) {
        
        // Begin playback
        delegate.play(track, PlaybackParams.defaultParams().withDelay(delay))
        assertWaitingTrack(track)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        
        XCTAssertEqual(PlaybackGapContext.gapLength, delay)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            self.assertGapStarted(nil, track)
        }
    }
    
    func doBeginPlayback_trackNeedsTranscoding(_ track: Track) {
        
        XCTAssertFalse(track.playbackNativelySupported)
        
        // Begin playback
        delegate.play(track)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, 1)
        XCTAssertEqual(sequencer.selectTrackCallCount, 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, 0)
            XCTAssertEqual(self.gapStartedMessages.count, 0)
        }
    }
    
    func doPausePlayback(_ track: Track) {
        
        let trackChangeMsgCountBefore = trackChangeMessages.count
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
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBefore)
            XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBefore)
        }
    }
    
    func doResumePlayback(_ track: Track) {
        
        let trackChangeMsgCountBefore = trackChangeMessages.count
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
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBefore)
            XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBefore)
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackChangeMsg = message as? TrackChangedAsyncMessage {
            
            trackChangeMessages.append(trackChangeMsg)
            return
            
        } else if let gapStartedMsg = message as? PlaybackGapStartedAsyncMessage {
            
            gapStartedMessages.append(gapStartedMsg)
            return
        }
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
    
    func createTrack(_ title: String, _ duration: Double, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        return createTrack(title, "mp3", duration, artist, album, genre)
    }
    
    func createTrack(_ title: String, _ fileExtension: String, _ duration: Double,
                     _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Dummy/%@.%@", title, fileExtension)))
        track.setPrimaryMetadata(artist, title, album, genre, duration)
        
        return track
    }
}
