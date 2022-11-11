//
//  EndPlaybackSequenceActionTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class EndPlaybackSequenceActionTests: AuralTestCase {
    
    var action: EndPlaybackSequenceAction!
    var sequencer: MockSequencer!
    
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
        
        sequencer = MockSequencer()
        action = EndPlaybackSequenceAction(sequencer)
        
        chain = MockPlaybackChain()
        
        messenger.subscribe(to: .player_preTrackPlayback, handler: self.preTrackPlayback(_:))
        messenger.subscribe(to: .player_trackTransitioned, handler: self.trackTransitioned(_:))
    }
    
    override func tearDown() {
        messenger.unsubscribeFromAll()
    }
    
    private func preTrackPlayback(_ notif: PreTrackPlaybackNotification) {
        
        preTrackPlaybackMsgCount.increment()
        
        preTrackPlaybackMsg_currentTrack = notif.oldTrack
        preTrackPlaybackMsg_currentState = notif.oldState
        preTrackPlaybackMsg_newTrack = notif.newTrack
    }

    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        trackTransitionMsgCount.increment()
        
        trackTransitionMsg_currentTrack = notif.beginTrack
        trackTransitionMsg_currentState = notif.beginState
        trackTransitionMsg_newTrack = notif.endTrack
    }
    
    func testEndPlaybackSequenceAction_noCurrentTrack() {
     
        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackPlayback(nil, .noTrack)
        assertTrackPlayback(nil, .noTrack)
        
        assertChainProceeded(context)
    }
    
    func testEndPlaybackSequenceAction_trackPlaying() {
     
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let context = PlaybackRequestContext(.playing, currentTrack, 125.353435, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackPlayback(currentTrack, .playing)
        assertTrackPlayback(currentTrack, .playing)
        
        assertChainProceeded(context)
    }
    
    func testEndPlaybackSequenceAction_trackPaused() {
     
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let context = PlaybackRequestContext(.paused, currentTrack, 125.353435, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackPlayback(currentTrack, .paused)
        assertTrackPlayback(currentTrack, .paused)
        
        assertChainProceeded(context)
    }
    
    private func assertPreTrackPlayback(_ currentTrack: Track?, _ currentState: PlaybackState) {
        
        XCTAssertEqual(preTrackPlaybackMsgCount, 1)
        XCTAssertEqual(preTrackPlaybackMsg_currentTrack, currentTrack)
        XCTAssertEqual(preTrackPlaybackMsg_currentState, currentState)
        XCTAssertEqual(preTrackPlaybackMsg_newTrack, nil)
    }
    
    private func assertTrackPlayback(_ currentTrack: Track?, _ currentState: PlaybackState) {
        
        XCTAssertEqual(trackTransitionMsgCount, 1)
        XCTAssertEqual(trackTransitionMsg_currentTrack, currentTrack)
        XCTAssertEqual(trackTransitionMsg_currentState, currentState)
        XCTAssertEqual(trackTransitionMsg_newTrack, nil)
    }
    
    private func assertChainProceeded(_ context: PlaybackRequestContext) {
        
        // Ensure chain completed
        
        XCTAssertEqual(chain.completionCount, 0)
        XCTAssertEqual(chain.terminationCount, 0)
        
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext === context)
    }
}
