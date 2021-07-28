//
//  StartPlaybackActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class StartPlaybackActionTests: AuralTestCase {

    var action: StartPlaybackAction!
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    var chain: MockPlaybackChain!
    
    var preTrackPlaybackMsgCount: Int = 0
    var preTrackPlaybackMsg_currentTrack: Track?
    var preTrackPlaybackMsg_currentState: PlaybackState?
    var preTrackPlaybackMsg_newTrack: Track?
    
    var trackTransitionMsgCount: Int = 0
    var trackTransitionMsg_currentTrack: Track?
    var trackTransitionMsg_currentState: PlaybackState?
    var trackTransitionMsg_newTrack: Track?
    
    private lazy var messenger = Messenger(for: self)

    override func setUp() {
        
        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(graph: mockPlayerGraph, avfScheduler: mockScheduler, ffmpegScheduler: mockScheduler)
        action = StartPlaybackAction(player)
        
        chain = MockPlaybackChain()
        
        messenger.subscribe(to: .player_preTrackPlayback, handler: self.preTrackPlayback(_:))
        messenger.subscribe(to: .player_trackTransitioned, handler: self.trackTransitioned(_:))
    }
    
    override func tearDown() {
        
        messenger.unsubscribeFromAll()
        player.stopListeningForMessages()
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        trackTransitionMsgCount.increment()
        
        trackTransitionMsg_currentTrack = notif.beginTrack
        trackTransitionMsg_currentState = notif.beginState
        trackTransitionMsg_newTrack = notif.endTrack
    }
    
    func preTrackPlayback(_ notif: PreTrackPlaybackNotification) {
        
        preTrackPlaybackMsgCount.increment()
        
        preTrackPlaybackMsg_currentTrack = notif.oldTrack
        preTrackPlaybackMsg_currentState = notif.oldState
        preTrackPlaybackMsg_newTrack = notif.newTrack
    }
    
    func testStartPlaybackAction_noRequestedTrack() {
     
        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(player.playCallCount, 0)
        XCTAssertEqual(preTrackPlaybackMsgCount, 0)
        XCTAssertEqual(trackTransitionMsgCount, 0)
        
        assertChainTerminated(context, error: NoRequestedTrackError.instance)
    }
    
    func testStartPlaybackAction_noStartOrEndPosition() {

        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, PlaybackParams.defaultParams())

        action.execute(context, chain)

        XCTAssertEqual(player.playCallCount, 1)
        XCTAssertEqual(player.play_track!, requestedTrack)
        XCTAssertEqual(player.play_startPosition!, 0)
        XCTAssertEqual(player.play_endPosition, nil)
        
        assertTrackPlayback(context)
        assertChainProceeded(context)
    }
    
    func testStartPlaybackAction_withStartPosition() {

        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestParams = PlaybackParams.defaultParams().withStartAndEndPosition(105.234234244)
        
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, requestParams)

        action.execute(context, chain)

        XCTAssertEqual(player.playCallCount, 1)
        XCTAssertEqual(player.play_track!, requestedTrack)
        XCTAssertEqual(player.play_startPosition!, requestParams.startPosition!)
        XCTAssertEqual(player.play_endPosition, nil)
        
        assertTrackPlayback(context)
        assertChainProceeded(context)
    }
    
    func testStartPlaybackAction_withStartAndEndPosition() {

        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestParams = PlaybackParams.defaultParams().withStartAndEndPosition(105.234234244, 236.33535366775)
        
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, requestParams)

        action.execute(context, chain)

        XCTAssertEqual(player.playCallCount, 1)
        XCTAssertEqual(player.play_track!, requestedTrack)
        XCTAssertEqual(player.play_startPosition!, requestParams.startPosition!)
        XCTAssertEqual(player.play_endPosition!, requestParams.endPosition!)
        
        assertTrackPlayback(context)
        assertChainProceeded(context)
    }
    
    func testStartPlaybackAction_trackPlaying() {

        let currentTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        
        let context = PlaybackRequestContext(.playing, currentTrack, 279.2213475675, requestedTrack, PlaybackParams.defaultParams())

        action.execute(context, chain)

        XCTAssertEqual(player.playCallCount, 1)
        XCTAssertEqual(player.play_track!, requestedTrack)
        XCTAssertEqual(player.play_startPosition!, 0)
        XCTAssertEqual(player.play_endPosition, nil)
        
        assertTrackPlayback(context)
        assertChainProceeded(context)
    }
    
    func testStartPlaybackAction_trackPaused() {

        let currentTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        
        let context = PlaybackRequestContext(.paused, currentTrack, 279.2213475675, requestedTrack, PlaybackParams.defaultParams())

        action.execute(context, chain)

        XCTAssertEqual(player.playCallCount, 1)
        XCTAssertEqual(player.play_track!, requestedTrack)
        XCTAssertEqual(player.play_startPosition!, 0)
        XCTAssertEqual(player.play_endPosition, nil)
        
        assertTrackPlayback(context)
        assertChainProceeded(context)
    }
    
    func testStartPlaybackAction_sameTrackRequested() {

        let currentTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        
        let context = PlaybackRequestContext(.playing, currentTrack, 279.2213475675, currentTrack, PlaybackParams.defaultParams())

        action.execute(context, chain)

        XCTAssertEqual(player.playCallCount, 1)
        XCTAssertEqual(player.play_track!, currentTrack)
        XCTAssertEqual(player.play_startPosition!, 0)
        XCTAssertEqual(player.play_endPosition, nil)
        
        assertTrackPlayback(context)
        assertChainProceeded(context)
    }
    
    private func assertTrackPlayback(_ context: PlaybackRequestContext) {
        
        let trackChanged = context.currentTrack != context.requestedTrack
        
        XCTAssertEqual(preTrackPlaybackMsgCount, trackChanged ? 1 : 0)
        
        if trackChanged {
            
            XCTAssertEqual(preTrackPlaybackMsg_currentTrack, context.currentTrack)
            XCTAssertEqual(preTrackPlaybackMsg_currentState, context.currentState)
            XCTAssertEqual(preTrackPlaybackMsg_newTrack!, context.requestedTrack!)
        }
        
        XCTAssertEqual(self.trackTransitionMsgCount, 1)
        XCTAssertEqual(self.trackTransitionMsg_currentTrack, context.currentTrack)
        XCTAssertEqual(self.trackTransitionMsg_currentState, context.currentState)
        XCTAssertEqual(self.trackTransitionMsg_newTrack!, context.requestedTrack!)
    }
    
    private func assertChainProceeded(_ context: PlaybackRequestContext) {
        
        // Ensure chain completed
        
        XCTAssertEqual(chain.completionCount, 0)
        XCTAssertEqual(chain.terminationCount, 0)
        
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext === context)
    }

    private func assertChainTerminated(_ context: PlaybackRequestContext, error: DisplayableError) {

        // Ensure chain was terminated and did not proceed
        XCTAssertEqual(chain.terminationCount, 1)
        XCTAssertTrue(chain.terminatedContext === context)
        XCTAssertTrue(chain.terminationError === error)
        XCTAssertEqual(chain.proceedCount, 0)
    }
}
