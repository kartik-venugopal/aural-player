import XCTest

class CancelTranscodingActionTests: AuralTestCase {

    var action: CancelTranscodingAction!
    var nextAction: MockPlaybackChainAction!
    
    var transcoder: MockTranscoder!
    
    override func setUp() {
        
        transcoder = MockTranscoder()
        action = CancelTranscodingAction(transcoder)
        
        nextAction = MockPlaybackChainAction()
        action.nextAction = nextAction
    }
    
    func testCancelTranscodingAction_noCurrentTrack_cancelTranscoding_requestedTrackDifferent() {
        
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackTranscoding_dontCancelTranscoding() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, false, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackTranscoding_cancelTranscoding_requestedTrackDifferent() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 1)
    }
    
    func testCancelTranscodingAction_trackTranscoding_cancelTranscoding_noRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, nil, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 1)
    }
    
    func testCancelTranscodingAction_trackTranscoding_cancelTranscoding_requestedTrackSame() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, currentTrack, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackPlaying_cancelTranscoding() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.playing, currentTrack, 304.3425435, requestedTrack, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackPaused_cancelTranscoding() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.paused, currentTrack, 304.3425435, requestedTrack, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackWaiting_cancelTranscoding() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, requestedTrack, true, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    private func doTestCancelTranscodingAction(_ context: PlaybackRequestContext, _ expectedTranscoderCancelCallCount: Int) {
        
        action.execute(context)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, expectedTranscoderCancelCallCount)
        XCTAssertEqual(transcoder.transcodeCancel_track, expectedTranscoderCancelCallCount == 0 ? nil : context.currentTrack!)
        
        XCTAssertEqual(nextAction.executionCount, 1)
        XCTAssertTrue(nextAction.executedContext! === context)
    }
}
