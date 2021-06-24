//
//  SpecificTrackPlaybackTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SpecificTrackPlaybackTests: PlaybackDelegateTests {
    
    // MARK: play(index) tests ------------------------------------------------------------------------------------

    func testPlayIndex_noTrack() {
        doPlayIndex(10)
    }
    
    func testPlayIndex_noTrack_delayInParams() {
        doPlayIndex_withDelay(10, 5, true)
    }
    
    func testPlayIndex_noTrack_gapBeforeTrack() {
        doPlayIndex_withDelay(10, 5)
    }
    
    func testPlayIndex_noTrack_trackNeedsTranscoding() {
        doPlayIndex_trackNeedsTranscoding(10)
    }
    
    func testPlayIndex_trackPaused() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayIndex(10)
    }
    
    func testPlayIndex_trackPaused_delayInParams() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayIndex_withDelay(10, 5, true)
    }
    
    func testPlayIndex_trackPaused_gapBeforeTrack() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayIndex_withDelay(10, 5)
    }
    
    func testPlayIndex_trackPaused_trackNeedsTranscoding() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayIndex_trackNeedsTranscoding(10)
    }
    
    func testPlayIndex_trackWaiting() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayIndex(10)
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPlayIndex_trackWaiting_delayInParams() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayIndex_withDelay(10, 10, true)
    }
    
    func testPlayIndex_trackWaiting_gapBeforeTrack() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayIndex_withDelay(10, 10)
    }
    
    func testPlayIndex_trackWaiting_trackNeedsTranscoding() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayIndex_trackNeedsTranscoding(10)
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPlayIndex_trackTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayIndex(10)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayIndex_trackTranscoding_delayInParams() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayIndex_withDelay(10, 5, true)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayIndex_trackTranscoding_gapBeforeTrack() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayIndex_withDelay(10, 5)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayIndex_trackTranscoding_trackNeedsTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayIndex_trackNeedsTranscoding(10)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayIndex_trackPlaying() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex(10)
    }
    
    func testPlayIndex_trackPlaying_delayInParams() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex_withDelay(10, 5, true)
    }
    
    func testPlayIndex_trackPlaying_gapBeforeTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex_withDelay(10, 5)
    }
    
    func testPlayIndex_trackPlaying_trackNeedsTranscoding() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayIndex_trackNeedsTranscoding(10)
    }
    
    private func doPlayIndex(_ index: Int) {
        
        let trackBeforeChange = delegate.currentTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        sequencer.selectionTracksByIndex[index] = track
        
        delegate.play(index)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, selectIndexCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedIndex, index)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(stateBeforeChange, trackBeforeChange,
                                                seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackTransitionMsgCountBeforeChange + 1)
    }
    
    private func doPlayIndex_withDelay(_ index: Int, _ delay: Double, _ defineDelayInParams: Bool = false) {
        
        let trackBeforeChange = delegate.currentTrack
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        
        let requestParams = PlaybackParams.defaultParams()
        
        if defineDelayInParams {
        
            _ = requestParams.withDelay(delay)
            XCTAssertEqual(requestParams.delay, delay)
            
        } else {
            
            playlist.setGapsForTrack(track, PlaybackGap(delay, .beforeTrack), nil)
            XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        }
        
        sequencer.selectionTracksByIndex[index] = track
        
        delegate.play(index, requestParams)
        assertWaitingTrack(track, delay)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, selectIndexCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedIndex, index)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        
        verifyRequestContext_startPlaybackChain(.waiting, track,
                                                seekPosBeforeChange, track, requestParams, true)
        
        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        self.assertGapStarted(trackBeforeChange, track, gapStartedMsgCountBeforeChange + 1)
    }
    
    private func doPlayIndex_trackNeedsTranscoding(_ index: Int) {
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let transcoderCallCountBeforeChange = transcoder.transcodeImmediatelyCallCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", "mka", 217.4565434)
        XCTAssertFalse(track.playbackNativelySupported)
        
        sequencer.selectionTracksByIndex[index] = track
        
        delegate.play(index)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectIndexCallCount, selectIndexCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedIndex, index)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, transcoderCallCountBeforeChange + 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(.transcoding, track,
        seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBeforeChange)
    }
    
    // MARK: play(track) tests ------------------------------------------------------------------------------------
    
    func testPlayTrack_noTrack() {
        doPlayTrack(createTrack("TestTrack", 200))
    }
    
    func testPlayTrack_noTrack_delayInParams() {
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 5, true)
    }
    
    func testPlayTrack_noTrack_gapBeforeTrack() {
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 5)
    }
    
    func testPlayTrack_noTrack_trackNeedsTranscoding() {
        doPlayTrack_trackNeedsTranscoding(createTrack("TestTrack", "ogg", 200))
    }
    
    func testPlayTrack_trackPaused() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayTrack(createTrack("TestTrack", 200))
    }
    
    func testPlayTrack_trackPaused_delayInParams() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayTrack_withDelay(createTrack("WaitingTrack", 200), 5, true)
    }
    
    func testPlayTrack_trackPaused_gapBeforeTrack() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayTrack_withDelay(createTrack("WaitingTrack", 200), 5)
    }
    
    func testPlayTrack_trackPaused_trackNeedsTranscoding() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayTrack_trackNeedsTranscoding(createTrack("TranscodingTrack", "ogg", 200))
    }
    
    func testPlayTrack_trackWaiting() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayTrack(createTrack("TestTrack", 200))
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPlayTrack_trackWaiting_delayInParams() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 12, true)
    }
    
    func testPlayTrack_trackWaiting_gapBeforeTrack() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 12)
    }
    
    func testPlayTrack_trackWaiting_trackNeedsTranscoding() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayTrack_trackNeedsTranscoding(createTrack("TestTrack", "wma", 200))
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPlayTrack_trackTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayTrack(createTrack("TestTrack", 200))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayTrack_trackTranscoding_delayInParams() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 5, true)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayTrack_trackTranscoding_gapBeforeTrack() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 5)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayTrack_trackTranscoding_trackNeedsTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayTrack_trackNeedsTranscoding(createTrack("TestTrack", "ogg", 200))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayTrack_trackPlaying() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack(createTrack("TestTrack", 200))
    }
    
    func testPlayTrack_trackPlaying_delayInParams() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 5, true)
    }
    
    func testPlayTrack_trackPlaying_gapBeforeTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack_withDelay(createTrack("TestTrack", 200), 5)
    }
    
    func testPlayTrack_trackPlaying_trackNeedsTranscoding() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayTrack_trackNeedsTranscoding(createTrack("TestTrack", "ogg", 200))
    }
    
    private func doPlayTrack(_ track: Track) {
        
        let trackBeforeChange = delegate.currentTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        delegate.play(track)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(stateBeforeChange, trackBeforeChange,
        seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackTransitionMsgCountBeforeChange + 1)
    }
    
    private func doPlayTrack_withDelay(_ track: Track, _ delay: Double, _ defineDelayInParams: Bool = false) {
        
        let trackBeforeChange = delegate.currentTrack
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count

        let requestParams = PlaybackParams.defaultParams()
        
        if defineDelayInParams {
        
            _ = requestParams.withDelay(delay)
            XCTAssertEqual(requestParams.delay, delay)
            
        } else {
            
            playlist.setGapsForTrack(track, PlaybackGap(delay, .beforeTrack), nil)
            XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        }
        
        delegate.play(track, requestParams)
        assertWaitingTrack(track, delay)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(.waiting, track,
                                                seekPosBeforeChange, track, requestParams, true)
        
        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        self.assertGapStarted(trackBeforeChange, track, gapStartedMsgCountBeforeChange + 1)
    }
    
    private func doPlayTrack_trackNeedsTranscoding(_ track: Track) {
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let transcoderCallCountBeforeChange = transcoder.transcodeImmediatelyCallCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        XCTAssertFalse(track.playbackNativelySupported)
        
        delegate.play(track)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, transcoderCallCountBeforeChange + 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(.transcoding, track,
        seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBeforeChange)
    }
    
    // MARK: play(group) tests ------------------------------------------------------------------------------------

    func testPlayGroup_noTrack() {
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    func testPlayGroup_noTrack_delayInParams() {
        doPlayGroup_withDelay(Group(.genre, "Electronica"), 5, true)
    }
    
    func testPlayGroup_noTrack_gapBeforeTrack() {
        doPlayGroup_withDelay(Group(.genre, "Electronica"), 5)
    }
    
    func testPlayGroup_noTrack_trackNeedsTranscoding() {
        doPlayGroup_trackNeedsTranscoding(Group(.genre, "Electronica"))
    }
    
    func testPlayGroup_trackPaused() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayGroup(Group(.genre, "Pop"))
    }
    
    func testPlayGroup_trackPaused_delayInParams() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayGroup_withDelay(Group(.genre, "Pop"), 5, true)
    }
    
    func testPlayGroup_trackPaused_gapBeforeTrack() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayGroup_withDelay(Group(.genre, "Pop"), 5)
    }
    
    func testPlayGroup_trackPaused_trackNeedsTranscoding() {
        
        let firstTrack = createTrack("FirstTrack", 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayGroup_trackNeedsTranscoding(Group(.genre, "Pop"))
    }
    
    func testPlayGroup_trackWaiting() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayGroup(Group(.artist, "Madonna"))
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPlayGroup_trackWaiting_delayInParams() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayGroup_withDelay(Group(.artist, "Madonna"), 12, true)
    }
    
    func testPlayGroup_trackWaiting_gapBeforeTrack() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayGroup_withDelay(Group(.artist, "Madonna"), 12)
    }
    
    func testPlayGroup_trackWaiting_trackNeedsTranscoding() {
        
        doBeginPlaybackWithDelay(createTrack("FirstTrack", 300), 5)
        doPlayGroup_trackNeedsTranscoding(Group(.artist, "Madonna"))
        
        XCTAssertNil(startPlaybackChain.executedContext!.delay)
    }
    
    func testPlayGroup_trackTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayGroup(Group(.album, "Exilarch"))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayGroup_trackTranscoding_delayInParams() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayGroup_withDelay(Group(.album, "Exilarch"), 5, true)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayGroup_trackTranscoding_gapBeforeTrack() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayGroup_withDelay(Group(.album, "Exilarch"), 5)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayGroup_trackTranscoding_trackNeedsTranscoding() {
        
        let track = createTrack("FirstTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        doPlayGroup_trackNeedsTranscoding(Group(.album, "Exilarch"))
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track, track)
    }
    
    func testPlayGroup_trackPlaying() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    func testPlayGroup_trackPlaying_delayInParams() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup_withDelay(Group(.genre, "Electronica"), 5, true)
    }
    
    func testPlayGroup_trackPlaying_gapBeforeTrack() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup_withDelay(Group(.genre, "Electronica"), 5)
    }
    
    func testPlayGroup_trackPlaying_trackNeedsTranscoding() {
        
        doBeginPlayback(createTrack("FirstTrack", 300))
        doPlayGroup_trackNeedsTranscoding(Group(.genre, "Electronica"))
    }
    
    private func doPlayGroup(_ group: Group) {
        
        let trackBeforeChange = delegate.currentTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        
        let track = createTrack("TestTrack", 217.4565434)
        sequencer.selectionTracksByGroup[group] = track
        
        delegate.play(group)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectGroupCallCount, selectGroupCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedGroup, group)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(stateBeforeChange, trackBeforeChange,
        seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackTransitionMsgCountBeforeChange + 1)
    }
    
    private func doPlayGroup_withDelay(_ group: Group, _ delay: Double, _ defineDelayInParams: Bool = false) {
        
        let trackBeforeChange = delegate.currentTrack
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count

        let track = createTrack("TestTrack", 217.4565434)
        
        let requestParams = PlaybackParams.defaultParams()
        
        if defineDelayInParams {
        
            _ = requestParams.withDelay(delay)
            XCTAssertEqual(requestParams.delay, delay)
            
        } else {
            
            playlist.setGapsForTrack(track, PlaybackGap(delay, .beforeTrack), nil)
            XCTAssertNotNil(playlist.getGapBeforeTrack(track))
        }
        
        sequencer.selectionTracksByGroup[group] = track
        
        delegate.play(group, requestParams)
        assertWaitingTrack(track, delay)
        
        XCTAssertEqual(sequencer.selectGroupCallCount, selectGroupCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedGroup, group)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(.waiting, track,
                                                seekPosBeforeChange, track, requestParams, true)
        
        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        self.assertGapStarted(trackBeforeChange, track, gapStartedMsgCountBeforeChange + 1)
    }
    
    private func doPlayGroup_trackNeedsTranscoding(_ group: Group) {
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let transcoderCallCountBeforeChange = transcoder.transcodeImmediatelyCallCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        let gapStartedMsgCountBeforeChange = gapStartedMessages.count
        
        let track = createTrack("TestTrack", "mka", 217.4565434)
        XCTAssertFalse(track.playbackNativelySupported)
        
        sequencer.selectionTracksByGroup[group] = track
        
        delegate.play(group)
        assertTranscodingTrack(track)
        
        XCTAssertEqual(sequencer.selectGroupCallCount, selectGroupCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedGroup, group)
        
        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, transcoderCallCountBeforeChange + 1)
        XCTAssertEqual(transcoder.transcodeImmediately_track, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(.transcoding, track,
        seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        XCTAssertEqual(self.trackTransitionMessages.count, trackTransitionMsgCountBeforeChange)
        XCTAssertEqual(self.gapStartedMessages.count, gapStartedMsgCountBeforeChange)
    }
}
