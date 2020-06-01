import XCTest

class PlaybackChainTests: AuralTestCase {
    
    var chain: TestablePlaybackChain!

    override func setUp() {
        chain = TestablePlaybackChain()
    }

    func testChainConstruction() {
        
        for numActions in [0, 1, 2, 3, 5, 10, 25, 50, 100] {
            doTestChainConstruction(numActions)
        }
    }
    
    func testExecute() {
        
        let track1 = createTrack("Hydropoetry Cathedra", 597)
        let track2 = createTrack("Sub-Sea Engineering", 360)
        
        for numActions in [0, 1, 2, 3, 5, 10, 25, 50, 100] {
            
            doTestChainConstruction(numActions, false)

            let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, true, PlaybackParams.defaultParams())
            chain.execute(context)
            XCTAssertTrue(PlaybackRequestContext.isCurrent(context))
            
            for actionIndex in 0..<numActions {
                
                let action = chain.actions[actionIndex] as! MockPlaybackChainAction
                XCTAssertEqual(action.executionCount, 1)
                XCTAssertTrue(action.executedContext! === context)
                XCTAssertNotNil(action.executionTimestamp)
                
                if actionIndex > 0 {
                    
                    // The execution timestamp of this action should be greater than that of the previous one.
                    // This establishes relative execution order of the 2 actions (i.e. this action executed after the previous one).
                    let previousAction = chain.actions[actionIndex - 1] as! MockPlaybackChainAction
                    XCTAssertGreaterThan(action.executionTimestamp!, previousAction.executionTimestamp!)
                }
            }
        }
    }
    
    private func doTestChainConstruction(_ length: Int, _ performAssertions: Bool = true) {
        
        chain = TestablePlaybackChain()
        
        for index in 0..<length {
            
            let action = MockPlaybackChainAction()
            _ = chain.withAction(action)
            
            if performAssertions {
            
                XCTAssertEqual(chain.actions.count, index + 1)
                XCTAssertTrue((chain.actions[index] as! MockPlaybackChainAction) === action)
                
                if index > 0 {
                    
                    // Ensure that the actions in the chain have been linked (through the nextAction property of each action)
                    // so that execution proceeds from one action to the next, in the intended order.
                    let previousAction = chain.actions[index - 1] as! MockPlaybackChainAction
                    XCTAssertTrue((previousAction.nextAction as! MockPlaybackChainAction) === action)
                }
            }
        }
    }
}
