import XCTest

class ValidateNewTrackActionTests: AuralTestCase, AsyncMessageSubscriber {

    var action: ValidateNewTrackAction!
    var sequencer: MockSequencer!
    
    var nextAction: MockPlaybackChainAction!
    
    var trackNotPlayedMsgCount: Int = 0
    var trackNotPlayedMsgTrack: Track?
    
    override func setUp() {
        
        sequencer = MockSequencer()
        action = ValidateNewTrackAction(sequencer)
        
        nextAction = MockPlaybackChainAction()
        action.nextAction = nextAction
        
        AsyncMessenger.subscribe([.trackNotPlayed], subscriber: self, dispatchQueue: .main)
    }
    
    override func tearDown() {
        AsyncMessenger.unsubscribe([.trackNotPlayed], subscriber: self)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
            
            trackNotPlayedMsgCount.increment()
            trackNotPlayedMsgTrack = trackNotPlayedMsg.error.track
            
            return
        }
    }
    
    func testValidateNewTrackAction_noRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.playing, currentTrack, 0, nil, true, PlaybackParams.defaultParams())
        
        // Begin the context
        PlaybackRequestContext.begun(context)
        
        action.execute(context)
        
        // Playback sequence should have ended.
        XCTAssertEqual(sequencer.endCallCount, 0)
        
        // Context should have completed, i.e. is no longer current,
        // because the chain should have been terminated due to the failed validation.
        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        
        // Ensure the next action was NOT executed
        XCTAssertEqual(nextAction.executionCount, 0)
    }
    
    func testValidateNewTrackAction_trackIsValid() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535, isValid: true)
        
        let context = PlaybackRequestContext(.playing, currentTrack, 0, requestedTrack, true, PlaybackParams.defaultParams())
        
        // Begin the context
        PlaybackRequestContext.begun(context)
        
        action.execute(context)
        
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparationFailed)
        XCTAssertNil(requestedTrack.lazyLoadingInfo.preparationError)

        XCTAssertEqual(sequencer.endCallCount, 0)
        XCTAssertTrue(PlaybackRequestContext.isCurrent(context))
        
        // Ensure the next action was executed (i.e. chain execution proceeded)
        XCTAssertEqual(nextAction.executionCount, 1)
        XCTAssertTrue(nextAction.executedContext! === context)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackNotPlayedMsgCount, 0)
            XCTAssertNil(self.trackNotPlayedMsgTrack)
        }
    }
    
    func testValidateNewTrackAction_trackIsInvalid() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535, isValid: false)
        
        let context = PlaybackRequestContext(.playing, currentTrack, 0, requestedTrack, true, PlaybackParams.defaultParams())
        
        // Begin the context
        PlaybackRequestContext.begun(context)
        
        action.execute(context)
        
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparationFailed)
        XCTAssertNotNil(requestedTrack.lazyLoadingInfo.preparationError)

        // Playback sequence should have ended.
        XCTAssertEqual(sequencer.endCallCount, 1)
        
        // Context should have completed, i.e. is no longer current,
        // because the chain should have been terminated due to the failed validation.
        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        
        // Ensure the next action was NOT executed
        XCTAssertEqual(nextAction.executionCount, 0)
        
        executeAfter(0.5) {
            
            XCTAssertEqual(self.trackNotPlayedMsgCount, 1)
            XCTAssertEqual(self.trackNotPlayedMsgTrack, requestedTrack)
        }
    }
}
