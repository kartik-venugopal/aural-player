//
//  PlaybackChainTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackChainTests: AuralTestCase {

    var chain: TestablePlaybackChain!

    override func setUp() {
        chain = TestablePlaybackChain()
    }

    func testChainConstruction() {

        for numActions in [0, 1, 2, 3, 5, 10, 25, 50, 100] {
            doTestChainConstruction(numActions, true)
        }
    }

    func testExecute() {

        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)

        for numActions in [0, 1, 2, 3, 5, 10, 25, 50, 100] {

            doTestChainConstruction(numActions, true, false)

            let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())
            chain.execute(context)

            // Context should have completed (i.e. no longer current)
            XCTAssertFalse(PlaybackRequestContext.isCurrent(context))

            XCTAssertEqual(chain.proceedCount, numActions + 1)
            XCTAssertEqual(chain.completionCount, 1)
            XCTAssertTrue(chain.completedContext! === context)

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

    func testProceed() {

        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)

        for numActions in [0, 1, 2, 3, 5, 10, 25, 50, 100] {

            doTestChainConstruction(numActions, false, false)

            let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())

            // Begin the context
            PlaybackRequestContext.begun(context)
            XCTAssertTrue(PlaybackRequestContext.isCurrent(context))

            // proceed() will be called (numActions + 1) times
            for actionIndex in 0...numActions {

                chain.proceed(context)

                // Do the following for all actionIndex values except the last (which results in chain completion)
                if actionIndex < numActions {

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

                    if actionIndex < numActions - 1 {

                        // Ensure that the next action has not yet been executed (i.e. verify execution order)
                        let nextAction = chain.actions[actionIndex + 1] as! MockPlaybackChainAction
                        XCTAssertEqual(nextAction.executionCount, 0)
                    }
                }
            }

            // Context should have completed (i.e. no longer current)
            XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
            XCTAssertEqual(chain.proceedCount, numActions + 1)

            XCTAssertEqual(chain.completionCount, 1)
            XCTAssertTrue(chain.completedContext! === context)
        }
    }

    func testComplete_noCurrentContext() {

        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())

        // No current context
        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        XCTAssertNil(PlaybackRequestContext.currentContext)

        chain.complete(context)

        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        XCTAssertNil(PlaybackRequestContext.currentContext)
    }

    func testComplete_hasCurrentContext() {

        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)

        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())

        // Begin the context
        PlaybackRequestContext.begun(context)
        XCTAssertTrue(PlaybackRequestContext.isCurrent(context))
        XCTAssertTrue(PlaybackRequestContext.currentContext! === context)

        chain.complete(context)

        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        XCTAssertNil(PlaybackRequestContext.currentContext)
    }

    func testTerminate_noCurrentContext() {

        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)

        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())

        // No current context
        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        XCTAssertNil(PlaybackRequestContext.currentContext)

        chain.terminate(context, NoAudioTracksError(track2.file))

        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        XCTAssertNil(PlaybackRequestContext.currentContext)
    }

    func testTerminate_hasCurrentContext() {

        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)

        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())

        // Begin the context
        PlaybackRequestContext.begun(context)
        XCTAssertTrue(PlaybackRequestContext.isCurrent(context))
        XCTAssertTrue(PlaybackRequestContext.currentContext! === context)

        chain.terminate(context, NoAudioTracksError(track2.file))

        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
        XCTAssertNil(PlaybackRequestContext.currentContext)
    }

    private func doTestChainConstruction(_ length: Int, _ proceedWithChainAfterExecution: Bool, _ performAssertions: Bool = true) {

        chain = TestablePlaybackChain()

        for index in 0..<length {

            let action = MockPlaybackChainAction(proceedWithChainAfterExecution)
            _ = chain.withAction(action)

            if performAssertions {

                XCTAssertEqual(chain.actions.count, index + 1)
                XCTAssertTrue((chain.actions[index] as! MockPlaybackChainAction) === action)
            }
        }
    }
}
