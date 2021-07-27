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

//class StartPlaybackActionTests: AuralTestCase, NotificationSubscriber {
//
//    var action: StartPlaybackAction!
//    var player: TestablePlayer!
//    var mockPlayerGraph: MockPlayerGraph!
//    var mockScheduler: MockScheduler!
//    var mockPlayerNode: MockPlayerNode!
//    
//    var chain: MockPlaybackChain!
//    
//    var preTrackChangeMsgCount: Int = 0
//    var preTrackChangeMsg_currentTrack: Track?
//    var preTrackChangeMsg_currentState: PlaybackState?
//    var preTrackChangeMsg_newTrack: Track?
//    
//    var trackTransitionMsgCount: Int = 0
//    var trackTransitionMsg_currentTrack: Track?
//    var trackTransitionMsg_currentState: PlaybackState?
//    var trackTransitionMsg_newTrack: Track?
//
//    override func setUp() {
//        
//        mockPlayerGraph = MockPlayerGraph()
//        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
//        mockScheduler = MockScheduler(mockPlayerNode)
//        
//        player = TestablePlayer(mockPlayerGraph, mockScheduler)
//        action = StartPlaybackAction(player)
//        
//        chain = MockPlaybackChain()
//        
//        Messenger.subscribe(self, .player_preTrackChange, self.preTrackChange(_:))
//        Messenger.subscribe(self, .player_trackTransitioned, self.trackTransitioned(_:))
//    }
//    
//    override func tearDown() {
//        Messenger.unsubscribeAll(for: self)
//    }
//    
//    func trackTransitioned(_ notif: TrackTransitionNotification) {
//        
//        trackTransitionMsgCount.increment()
//        
//        trackTransitionMsg_currentTrack = notif.beginTrack
//        trackTransitionMsg_currentState = notif.beginState
//        trackTransitionMsg_newTrack = notif.endTrack
//    }
//    
//    func preTrackChange(_ notif: PreTrackChangeNotification) {
//        
//        preTrackChangeMsgCount.increment()
//        
//        preTrackChangeMsg_currentTrack = notif.oldTrack
//        preTrackChangeMsg_currentState = notif.oldState
//        preTrackChangeMsg_newTrack = notif.newTrack
//    }
//    
//    func testStartPlaybackAction_noRequestedTrack() {
//     
//        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
//        
//        action.execute(context, chain)
//        
//        XCTAssertEqual(player.playCallCount, 0)
//        XCTAssertEqual(preTrackChangeMsgCount, 0)
//        XCTAssertEqual(trackTransitionMsgCount, 0)
//        
//        assertChainTerminated(context)
//    }
//    
//    func testStartPlaybackAction_noStartOrEndPosition() {
//
//        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, PlaybackParams.defaultParams())
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.playCallCount, 1)
//        XCTAssertEqual(player.play_track!, requestedTrack)
//        XCTAssertEqual(player.play_startPosition!, 0)
//        XCTAssertEqual(player.play_endPosition, nil)
//        
//        assertTrackChange(context)
//        assertChainCompleted(context)
//    }
//    
//    func testStartPlaybackAction_withStartPosition() {
//
//        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestParams = PlaybackParams.defaultParams().withStartPosition(105.234234244)
//        
//        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, requestParams)
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.playCallCount, 1)
//        XCTAssertEqual(player.play_track!, requestedTrack)
//        XCTAssertEqual(player.play_startPosition!, requestParams.startPosition!)
//        XCTAssertEqual(player.play_endPosition, nil)
//        
//        assertTrackChange(context)
//        assertChainCompleted(context)
//    }
//    
//    func testStartPlaybackAction_withStartAndEndPosition() {
//
//        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestParams = PlaybackParams.defaultParams().withStartAndEndPosition(105.234234244, 236.33535366775)
//        
//        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, requestParams)
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.playCallCount, 1)
//        XCTAssertEqual(player.play_track!, requestedTrack)
//        XCTAssertEqual(player.play_startPosition!, requestParams.startPosition!)
//        XCTAssertEqual(player.play_endPosition!, requestParams.endPosition!)
//        
//        assertTrackChange(context)
//        assertChainCompleted(context)
//    }
//    
//    func testStartPlaybackAction_trackPlaying() {
//
//        let currentTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        
//        let context = PlaybackRequestContext(.playing, currentTrack, 279.2213475675, requestedTrack, PlaybackParams.defaultParams())
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.playCallCount, 1)
//        XCTAssertEqual(player.play_track!, requestedTrack)
//        XCTAssertEqual(player.play_startPosition!, 0)
//        XCTAssertEqual(player.play_endPosition, nil)
//        
//        assertTrackChange(context)
//        assertChainCompleted(context)
//    }
//    
//    func testStartPlaybackAction_trackPaused() {
//
//        let currentTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//        let requestedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        
//        let context = PlaybackRequestContext(.paused, currentTrack, 279.2213475675, requestedTrack, PlaybackParams.defaultParams())
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.playCallCount, 1)
//        XCTAssertEqual(player.play_track!, requestedTrack)
//        XCTAssertEqual(player.play_startPosition!, 0)
//        XCTAssertEqual(player.play_endPosition, nil)
//        
//        assertTrackChange(context)
//        assertChainCompleted(context)
//    }
//    
//    func testStartPlaybackAction_sameTrackRequested() {
//
//        let currentTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//        
//        let context = PlaybackRequestContext(.playing, currentTrack, 279.2213475675, currentTrack, PlaybackParams.defaultParams())
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.playCallCount, 1)
//        XCTAssertEqual(player.play_track!, currentTrack)
//        XCTAssertEqual(player.play_startPosition!, 0)
//        XCTAssertEqual(player.play_endPosition, nil)
//        
//        assertTrackChange(context)
//        assertChainCompleted(context)
//    }
//    
//    private func assertTrackChange(_ context: PlaybackRequestContext) {
//        
//        let trackChanged = context.currentTrack != context.requestedTrack
//        
//        XCTAssertEqual(preTrackChangeMsgCount, trackChanged ? 1 : 0)
//        
//        if trackChanged {
//            
//            XCTAssertEqual(preTrackChangeMsg_currentTrack, context.currentTrack)
//            XCTAssertEqual(preTrackChangeMsg_currentState, context.currentState)
//            XCTAssertEqual(preTrackChangeMsg_newTrack!, context.requestedTrack!)
//        }
//        
//        XCTAssertEqual(self.trackTransitionMsgCount, 1)
//        XCTAssertEqual(self.trackTransitionMsg_currentTrack, context.currentTrack)
//        XCTAssertEqual(self.trackTransitionMsg_currentState, context.currentState)
//        XCTAssertEqual(self.trackTransitionMsg_newTrack!, context.requestedTrack!)
//    }
//    
//    private func assertChainCompleted(_ context: PlaybackRequestContext) {
//        
//        // Ensure chain completed
//        
//        XCTAssertEqual(chain.proceedCount, 0)
//        XCTAssertEqual(chain.terminationCount, 0)
//        
//        XCTAssertEqual(chain.completionCount, 1)
//        XCTAssertTrue(chain.completedContext! === context)
//    }
//
//    private func assertChainTerminated(_ context: PlaybackRequestContext) {
//        
//        // Ensure chain was terminated
//        XCTAssertEqual(chain.terminationCount, 1)
//        XCTAssertTrue(chain.terminatedContext! === context)
//    }
//}
