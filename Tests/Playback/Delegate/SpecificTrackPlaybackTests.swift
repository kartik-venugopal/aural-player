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
    
    func testPlayIndex_trackPaused() {
        
        let firstTrack = createTrack(title: "FirstTrack", duration: 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayIndex(10)
    }
    
    func testPlayIndex_trackPlaying() {
        
        doBeginPlayback(createTrack(title: "FirstTrack", duration: 300))
        doPlayIndex(10)
    }
    
    private func doPlayIndex(_ index: Int) {
        
        let trackBeforeChange = delegate.playingTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectIndexCallCountBeforeChange = sequencer.selectIndexCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        
        let track = createTrack(title: "TestTrack", duration: 217.4565434)
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
        
    // MARK: play(track) tests ------------------------------------------------------------------------------------
    
    func testPlayTrack_noTrack() {
        doPlayTrack(createTrack(title: "TestTrack", duration: 200))
    }
    
    func testPlayTrack_trackPaused() {
        
        let firstTrack = createTrack(title: "FirstTrack", duration: 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayTrack(createTrack(title: "TestTrack", duration: 200))
    }
    
    func testPlayTrack_trackPlaying() {
        
        doBeginPlayback(createTrack(title: "FirstTrack", duration: 300))
        doPlayTrack(createTrack(title: "TestTrack", duration: 200))
    }
    
    private func doPlayTrack(_ track: Track) {
        
        let trackBeforeChange = delegate.playingTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectTrackCallCountBeforeChange = sequencer.selectTrackCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        
        let track = createTrack(title: "TestTrack", duration: 217.4565434)
        delegate.play(track)
        assertPlayingTrack(track)
        
        XCTAssertEqual(sequencer.selectTrackCallCount, selectTrackCallCountBeforeChange + 1)
        XCTAssertEqual(sequencer.selectedTrack, track)
        
        XCTAssertEqual(startPlaybackChain.executionCount, startPlaybackChainCallCountBeforeChange + 1)
        verifyRequestContext_startPlaybackChain(stateBeforeChange, trackBeforeChange,
        seekPosBeforeChange, track, PlaybackParams.defaultParams(), true)
        
        self.assertTrackChange(trackBeforeChange, stateBeforeChange, track, trackTransitionMsgCountBeforeChange + 1)
    }
    
    // MARK: play(group) tests ------------------------------------------------------------------------------------

    func testPlayGroup_noTrack() {
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    func testPlayGroup_trackPaused() {
        
        let firstTrack = createTrack(title: "FirstTrack", duration: 300)
        doBeginPlayback(firstTrack)
        doPausePlayback(firstTrack)
        
        doPlayGroup(Group(.genre, "Pop"))
    }
    
    func testPlayGroup_trackPlaying() {
        
        doBeginPlayback(createTrack(title: "FirstTrack", duration: 300))
        doPlayGroup(Group(.artist, "Madonna"))
    }
    
    private func doPlayGroup(_ group: Group) {
        
        let trackBeforeChange = delegate.playingTrack
        let stateBeforeChange = delegate.state
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        let selectGroupCallCountBeforeChange = sequencer.selectGroupCallCount
        let startPlaybackChainCallCountBeforeChange = startPlaybackChain.executionCount
        
        let trackTransitionMsgCountBeforeChange = trackTransitionMessages.count
        
        let track = createTrack(title: "TestTrack", duration: 217.4565434)
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
}
