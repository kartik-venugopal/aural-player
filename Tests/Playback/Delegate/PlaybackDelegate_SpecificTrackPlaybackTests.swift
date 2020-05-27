import XCTest

class PlaybackDelegate_SpecificTrackPlaybackTests: PlaybackDelegateTests {
    
    // MARK: play(index) tests ------------------------------------------------------------------------------------

    func testPlayIndex_noTrack() {
        doPlayIndex(10)
    }
    
    func testPlayIndex_noTrack_gapBeforeTrack() {
        doPlayIndex_gapBeforeTrack(10, 5)
    }
    
    func testPlayIndex_noTrack_trackNeedsTranscoding() {
        doPlayIndex_trackNeedsTranscoding(10)
    }
    
    func testPlayIndex_trackPlaying() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex(10)
    }
    
    func testPlayIndex_trackPaused() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayIndex(10)
    }
    
    func testPlayIndex_trackWaiting() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayIndex(10)
    }
    
    func testPlayIndex_trackTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayIndex(10)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancelTrack, track)
    }
    
    func testPlayIndex_trackPlaying_gapBeforeTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex_gapBeforeTrack(10, 5)
    }
    
    func testPlayIndex_trackPlaying_trackNeedsTranscoding() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex_trackNeedsTranscoding(10)
    }
    
    private func doPlayIndex(_ index: Int) {
        
        let trackBeforeChange = delegate.currentTrack
        let stateBeforeChange = delegate.state
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        sequencer.selectionTracksByIndex[index] = track
        
        delegate.play(index)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, selectIndexCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedIndex, index)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackChangeMsgCountBeforeChange + 1)
        }
    }
    
    private func doPlayIndex_gapBeforeTrack(_ index: Int, _ gapBeforeTrack: Double) {
        
        let trackBeforeChange = delegate.currentTrack
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        
        playlist.setGapsForTrack(track, PlaybackGap(gapBeforeTrack, .beforeTrack), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        
        sequencer.selectionTracksByIndex[index] = track
        
        delegate.play(index)
        assertWaitingTrack(track)
        XCTAssertEqual(PlaybackGapContext.gapLength, gapBeforeTrack)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, selectIndexCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedIndex, index)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBeforeChange)
            self.assertGapStarted(trackBeforeChange, track, gapStartedMsgCountBeforeChange + 1)
        }
    }
    
    private func doPlayIndex_trackNeedsTranscoding(_ index: Int) {
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", "mka", 217.4565434)
        XCTAssertFalse(track.playbackNativelySupported)
        
        sequencer.selectionTracksByIndex[index] = track
        
        delegate.play(index)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, selectIndexCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedIndex, index)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBeforeChange)
            XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBeforeChange)
        }
    }
    
    // MARK: play(track) tests ------------------------------------------------------------------------------------
    
    func testPlayTrack_noTrack() {
        doPlayTrack(createTrack("TestTrack", 200))
    }
    
    func testPlayTrack_noTrack_gapBeforeTrack() {
        doPlayTrack_gapBeforeTrack(createTrack("TestTrack", 200), 5)
    }
    
    func testPlayTrack_noTrack_trackNeedsTranscoding() {
        doPlayTrack_trackNeedsTranscoding(createTrack("TestTrack", "ogg", 200))
    }
    
    func testPlayTrack_trackPlaying() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack(createTrack("TestTrack", 200))
    }
    
    func testPlayTrack_trackPaused() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayTrack(createTrack("TestTrack", 200))
    }
    
    func testPlayTrack_trackWaiting() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayTrack(createTrack("TestTrack", 200))
        
        XCTAssertFalse(PlaybackGapContext.hasGaps())
    }
    
    func testPlayTrack_trackTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayTrack(createTrack("TestTrack", 200))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancelTrack, track)
    }
    
    func testPlayTrack_trackPlaying_gapBeforeTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack_gapBeforeTrack(createTrack("TestTrack", 200), 5)
    }
    
    func testPlayTrack_trackPlaying_trackNeedsTranscoding() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack_trackNeedsTranscoding(createTrack("TestTrack", "ogg", 200))
    }
    
    private func doPlayTrack(_ track: Track) {
        
        let trackBeforeChange = delegate.currentTrack
        let stateBeforeChange = delegate.state
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        delegate.play(track)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackChangeMsgCountBeforeChange + 1)
        }
    }
    
    private func doPlayTrack_gapBeforeTrack(_ track: Track, _ gapBeforeTrack: Double) {
        
        let trackBeforeChange = delegate.currentTrack
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        playlist.setGapsForTrack(track, PlaybackGap(gapBeforeTrack, .beforeTrack), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        
        delegate.play(track)
        assertWaitingTrack(track)
        XCTAssertEqual(PlaybackGapContext.gapLength, gapBeforeTrack)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBeforeChange)
            self.assertGapStarted(trackBeforeChange, track, gapStartedMsgCountBeforeChange + 1)
        }
    }
    
    private func doPlayTrack_trackNeedsTranscoding(_ track: Track) {
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        XCTAssertFalse(track.playbackNativelySupported)
        
        delegate.play(track)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBeforeChange)
            XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBeforeChange)
        }
    }
    
    // MARK: play(group) tests ------------------------------------------------------------------------------------

    func testPlayGroup_noTrack() {
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    func testPlayGroup_noTrack_gapBeforeTrack() {
        doPlayGroup_gapBeforeTrack(Group(.genre, "Electronica"), 5)
    }
    
    func testPlayGroup_noTrack_trackNeedsTranscoding() {
        doPlayGroup_trackNeedsTranscoding(Group(.genre, "Electronica"))
    }
    
    func testPlayGroup_trackPlaying() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    func testPlayGroup_trackPaused() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayGroup(Group(.genre, "Pop"))
    }
    
    func testPlayGroup_trackWaiting() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    func testPlayGroup_trackTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayGroup(Group(.album, "Exilarch"))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancelTrack, track)
    }
    
    func testPlayGroup_trackPlaying_gapBeforeTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup_gapBeforeTrack(Group(.genre, "Electronica"), 5)
    }
    
    func testPlayGroup_trackPlaying_trackNeedsTranscoding() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup_trackNeedsTranscoding(Group(.genre, "Electronica"))
    }
    
    private func doPlayGroup(_ group: Group) {
        
        let trackBeforeChange = delegate.currentTrack
        let stateBeforeChange = delegate.state
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        sequencer.selectionTracksByGroup[group] = track
        
        delegate.play(group)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectGroupCallCount, selectGroupCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedGroup, group)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackChangeMsgCountBeforeChange + 1)
        }
    }
    
    private func doPlayGroup_gapBeforeTrack(_ group: Group, _ gapBeforeTrack: Double) {
        
        let trackBeforeChange = delegate.currentTrack
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        
        playlist.setGapsForTrack(track, PlaybackGap(gapBeforeTrack, .beforeTrack), nil)
        XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        
        sequencer.selectionTracksByGroup[group] = track
        
        delegate.play(group)
        assertWaitingTrack(track)
        XCTAssertEqual(PlaybackGapContext.gapLength, gapBeforeTrack)
        
        XCTAssertEqual(sequencer.selectGroupCallCount, selectGroupCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedGroup, group)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBeforeChange)
            self.assertGapStarted(trackBeforeChange, track, gapStartedMsgCountBeforeChange + 1)
        }
    }
    
    private func doPlayGroup_trackNeedsTranscoding(_ group: Group) {
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackChangeMsgCountBeforeChange = trackChangeMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", "mka", 217.4565434)
        XCTAssertFalse(track.playbackNativelySupported)
        
        sequencer.selectionTracksByGroup[group] = track
        
        delegate.play(group)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectGroupCallCount, selectGroupCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedGroup, group)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
        XCTAssertEqual(transcoder.transcodeImmediatelyTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        executeAfter(0.5) {
            XCTAssertEqual(self.trackChangeMessages.count, trackChangeMsgCountBeforeChange)
            XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBeforeChange)
        }
    }
}
