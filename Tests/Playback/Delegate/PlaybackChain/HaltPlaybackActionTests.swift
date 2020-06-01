import XCTest

class HaltPlaybackActionTests: AuralTestCase {
    
    var action: HaltPlaybackAction!
    var nextAction: MockPlaybackChainAction!
    
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    override func setUp() {
        
        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(mockPlayerGraph, mockScheduler)
        action = HaltPlaybackAction(player)
        
        nextAction = MockPlaybackChainAction()
        action.nextAction = nextAction
    }

    func testHaltPlaybackAction_noTrack() {
        
        let newTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.noTrack, nil, 0, newTrack, true, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 0)
    }
    
    func testHaltPlaybackAction_playing() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let newTrack = createTrack("Sub-Sea Engineering", 360)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, newTrack, true, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 1)
    }
    
    func testHaltPlaybackAction_paused() {

        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let newTrack = createTrack("Sub-Sea Engineering", 360)
        
        let context = PlaybackRequestContext(.paused, currentTrack, 101.327623, newTrack, true, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 1)
    }
    
    func testHaltPlaybackAction_waiting() {

        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let newTrack = createTrack("Sub-Sea Engineering", 360)
        
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, newTrack, true, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 1)
    }
    
    func testHaltPlaybackAction_transcoding() {

        let currentTrack = createTrack("Hydropoetry Cathedra", "ogg", 597)
        let newTrack = createTrack("Sub-Sea Engineering", 360)
        
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, newTrack, true, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 1)
    }
    
    private func doTestHaltPlaybackAction(_ context: PlaybackRequestContext, _ expectedPlayerStopCallCount: Int) {
        
        action.execute(context)
        
        XCTAssertEqual(player.stopCallCount,expectedPlayerStopCallCount)
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        
        XCTAssertEqual(nextAction.executionCount, 1)
        XCTAssertTrue(nextAction.executedContext! === context)
    }
}
