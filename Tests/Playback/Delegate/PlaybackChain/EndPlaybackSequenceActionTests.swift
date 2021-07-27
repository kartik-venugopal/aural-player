//
//  EndPlaybackSequenceActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

//class EndPlaybackSequenceActionTests: AuralTestCase, NotificationSubscriber {
//    
//    var action: EndPlaybackSequenceAction!
//    var sequencer: MockSequencer!
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
//        sequencer = MockSequencer()
//        action = EndPlaybackSequenceAction(sequencer)
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
//    func preTrackChange(_ notif: PreTrackChangeNotification) {
//        
//        preTrackChangeMsgCount.increment()
//        
//        preTrackChangeMsg_currentTrack = notif.oldTrack
//        preTrackChangeMsg_currentState = notif.oldState
//        preTrackChangeMsg_newTrack = notif.newTrack
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
//    func testEndPlaybackSequenceAction_noCurrentTrack() {
//     
//        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
//        
//        action.execute(context, chain)
//        
//        XCTAssertEqual(sequencer.endCallCount, 1)
//        
//        assertPreTrackChange(nil, .noTrack)
//        assertTrackChange(nil, .noTrack)
//        
//        assertChainCompleted(context)
//    }
//    
//    func testEndPlaybackSequenceAction_trackPlaying() {
//     
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context = PlaybackRequestContext(.playing, currentTrack, 125.353435, nil, PlaybackParams.defaultParams())
//        
//        action.execute(context, chain)
//        
//        XCTAssertEqual(sequencer.endCallCount, 1)
//        
//        assertPreTrackChange(currentTrack, .playing)
//        assertTrackChange(currentTrack, .playing)
//        
//        assertChainCompleted(context)
//    }
//    
//    func testEndPlaybackSequenceAction_trackPaused() {
//     
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context = PlaybackRequestContext(.paused, currentTrack, 125.353435, nil, PlaybackParams.defaultParams())
//        
//        action.execute(context, chain)
//        
//        XCTAssertEqual(sequencer.endCallCount, 1)
//        
//        assertPreTrackChange(currentTrack, .paused)
//        assertTrackChange(currentTrack, .paused)
//        
//        assertChainCompleted(context)
//    }
//    
//    func testEndPlaybackSequenceAction_trackWaiting() {
//     
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context = PlaybackRequestContext(.waiting, currentTrack, 0, nil, PlaybackParams.defaultParams())
//        
//        action.execute(context, chain)
//        
//        XCTAssertEqual(sequencer.endCallCount, 1)
//        
//        assertPreTrackChange(currentTrack, .waiting)
//        assertTrackChange(currentTrack, .waiting)
//        
//        assertChainCompleted(context)
//    }
//    
//    func testEndPlaybackSequenceAction_trackTranscoding() {
//     
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, nil, PlaybackParams.defaultParams())
//        
//        action.execute(context, chain)
//        
//        XCTAssertEqual(sequencer.endCallCount, 1)
//        
//        assertPreTrackChange(currentTrack, .transcoding)
//        assertTrackChange(currentTrack, .transcoding)
//        
//        assertChainCompleted(context)
//    }
//    
//    private func assertPreTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState) {
//        
//        XCTAssertEqual(preTrackChangeMsgCount, 1)
//        XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
//        XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
//        XCTAssertEqual(preTrackChangeMsg_newTrack, nil)
//    }
//    
//    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState) {
//        
//        XCTAssertEqual(self.trackTransitionMsgCount, 1)
//        XCTAssertEqual(self.trackTransitionMsg_currentTrack, currentTrack)
//        XCTAssertEqual(self.trackTransitionMsg_currentState, currentState)
//        XCTAssertEqual(self.trackTransitionMsg_newTrack, nil)
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
//}
