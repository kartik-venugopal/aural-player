import XCTest

class EndPlaybackSequenceActionTests: AuralTestCase, MessageSubscriber, AsyncMessageSubscriber {
    
    var action: EndPlaybackSequenceAction!
    var sequencer: MockSequencer!
    
    var chain: MockPlaybackChain!
    
    var preTrackChangeMsgCount: Int = 0
    var preTrackChangeMsg_currentTrack: Track?
    var preTrackChangeMsg_currentState: PlaybackState?
    var preTrackChangeMsg_newTrack: Track?
    
    var trackChangeMsgCount: Int = 0
    var trackChangeMsg_currentTrack: Track?
    var trackChangeMsg_currentState: PlaybackState?
    var trackChangeMsg_newTrack: Track?

    override func setUp() {
        
        sequencer = MockSequencer()
        action = EndPlaybackSequenceAction(sequencer)
        
        chain = MockPlaybackChain()
        
        SyncMessenger.subscribe(messageTypes: [.preTrackChangeNotification], subscriber: self)
        AsyncMessenger.subscribe([.trackChanged], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
    }
    
    override func tearDown() {
        
        SyncMessenger.unsubscribe(messageTypes: [.preTrackChangeNotification], subscriber: self)
        AsyncMessenger.unsubscribe([.trackChanged], subscriber: self)
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? PreTrackChangeNotification {
            
            preTrackChangeMsgCount.increment()
            
            preTrackChangeMsg_currentTrack = msg.oldTrack
            preTrackChangeMsg_currentState = msg.oldState
            preTrackChangeMsg_newTrack = msg.newTrack
            
            return
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackChangeMsg = message as? TrackChangedAsyncMessage {
            
            trackChangeMsgCount.increment()
            
            trackChangeMsg_currentTrack = trackChangeMsg.oldTrack
            trackChangeMsg_currentState = trackChangeMsg.oldState
            trackChangeMsg_newTrack = trackChangeMsg.newTrack
            
            return
        }
    }
    
    func testEndPlaybackSequenceAction_noCurrentTrack() {
     
        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackChange(nil, .noTrack)
        assertTrackChange(nil, .noTrack)
    }
    
    func testEndPlaybackSequenceAction_trackPlaying() {
     
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.playing, currentTrack, 125.353435, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackChange(currentTrack, .playing)
        assertTrackChange(currentTrack, .playing)
    }
    
    func testEndPlaybackSequenceAction_trackPaused() {
     
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.paused, currentTrack, 125.353435, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackChange(currentTrack, .paused)
        assertTrackChange(currentTrack, .paused)
    }
    
    func testEndPlaybackSequenceAction_trackWaiting() {
     
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackChange(currentTrack, .waiting)
        assertTrackChange(currentTrack, .waiting)
    }
    
    func testEndPlaybackSequenceAction_trackTranscoding() {
     
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        assertPreTrackChange(currentTrack, .transcoding)
        assertTrackChange(currentTrack, .transcoding)
    }
    
    private func assertPreTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState) {
        
        XCTAssertEqual(preTrackChangeMsgCount, 1)
        XCTAssertEqual(preTrackChangeMsg_currentTrack, currentTrack)
        XCTAssertEqual(preTrackChangeMsg_currentState, currentState)
        XCTAssertEqual(preTrackChangeMsg_newTrack, nil)
    }
    
    private func assertTrackChange(_ currentTrack: Track?, _ currentState: PlaybackState) {
        
        executeAfter(0.5) {
        
            XCTAssertEqual(self.trackChangeMsgCount, 1)
            XCTAssertEqual(self.trackChangeMsg_currentTrack, currentTrack)
            XCTAssertEqual(self.trackChangeMsg_currentState, currentState)
            XCTAssertEqual(self.trackChangeMsg_newTrack, nil)
        }
    }
}
