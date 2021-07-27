//
//  AudioFilePreparationActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

//class AudioFilePreparationActionTests: AuralTestCase, NotificationSubscriber {
//
//    var action: AudioFilePreparationAction!
//    var chain: MockPlaybackChain!
//
//    var player: TestablePlayer!
//    var mockPlayerGraph: MockPlayerGraph!
//    var mockScheduler: MockScheduler!
//    var mockPlayerNode: MockPlayerNode!
//
//    var transcoder: MockTranscoder!
//
//    var gapStartedMsgCount: Int = 0
//    var gapStartedMsg_oldTrack: Track?
//    var gapStartedMsg_newTrack: Track?
//    var gapStartedMsg_endTime: Date?
//
//    override func setUp() {
//
//        mockPlayerGraph = MockPlayerGraph()
//        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
//        mockScheduler = MockScheduler(mockPlayerNode)
//
//        player = TestablePlayer(mockPlayerGraph, mockScheduler)
//        transcoder = MockTranscoder()
//
//        action = AudioFilePreparationAction(player, transcoder)
//        chain = MockPlaybackChain()
//
//        Messenger.subscribe(self, .player_trackTransitioned, self.gapStarted(_:), filter: {notif in notif.gapStarted})
//
//        PlaybackRequestContext.clearCurrentContext()
//    }
//
//    override func tearDown() {
//        Messenger.unsubscribeAll(for: self)
//    }
//
//    func gapStarted(_ notif: TrackTransitionNotification) {
//
//        gapStartedMsgCount.increment()
//
//        gapStartedMsg_oldTrack = notif.beginTrack
//        gapStartedMsg_endTime = notif.gapEndTime
//        gapStartedMsg_newTrack = notif.endTrack
//    }
//
//    func testAudioFilePreparationAction_noRequestedTrack() {
//
//        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams())
//
//        action.execute(context, chain)
//
//        XCTAssertEqual(player.waitingCallCount, 0)
//
//        assertChainTerminated(context)
//        assertGapNotStarted()
//    }
//
//    func testAudioFilePreparationAction_dontAllowDelay() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams().withAllowDelay(false))
//
//        // Define a total delay time of 2 seconds (should be ignored because allowDelay = false)
//        context.addGap(PlaybackGap(2, .beforeTrack))
//        XCTAssertEqual(context.delay!, 2)
//
//        action.execute(context, chain)
//
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertEqual(player.waitingCallCount, 0)
//
//        assertGapNotStarted()
//        assertChainProceeded(context)
//    }
//
//    func testAudioFilePreparationAction_noDelayDefined() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No delay defined
//        XCTAssertNil(context.delay)
//
//        action.execute(context, chain)
//
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertEqual(player.waitingCallCount, 0)
//
//        assertGapNotStarted()
//        assertChainProceeded(context)
//    }
//
//    func testAudioFilePreparationAction_noDelayDefined_invalidTrack() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack("Brothers in Arms", 302.34534535, isValid: false)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No delay defined
//        XCTAssertNil(context.delay)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertEqual(player.waitingCallCount, 0)
//        XCTAssertEqual(player.transcodingCallCount, 0)
//
//        assertGapNotStarted()
//        assertChainTerminated(context)
//    }
//
//    func testAudioFilePreparationAction_delayDefined() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // Define a total delay time of 3 seconds
//        context.addGap(PlaybackGap(2, .afterTrack))
//        context.addGap(PlaybackGap(1, .beforeTrack))
//        XCTAssertEqual(context.delay!, 3)
//
//        // Mark the context as having begun execution (otherwise, playback will not proceed after the delay)
//        PlaybackRequestContext.begun(context)
//
//        action.execute(context, chain)
//
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertEqual(player.state, PlaybackState.waiting)
//        XCTAssertEqual(player.waitingCallCount, 1)
//
//        assertChainDeferred(context)
//        assertGapStarted(currentTrack, requestedTrack)
//
//        waitAndAssertChainProceeded(context)
//        XCTAssertEqual(context.currentState, PlaybackState.waiting)
//    }
//
//    func testAudioFilePreparationAction_delayDefined_invalidTrack() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack("Brothers in Arms", 302.34534535, isValid: false)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // Define a total delay time of 3 seconds
//        context.addGap(PlaybackGap(2, .afterTrack))
//        context.addGap(PlaybackGap(1, .beforeTrack))
//        XCTAssertEqual(context.delay!, 3)
//
//        // Mark the context as having begun execution (otherwise, playback will not proceed after the delay)
//        PlaybackRequestContext.begun(context)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertEqual(player.waitingCallCount, 0)
//        XCTAssertEqual(player.transcodingCallCount, 0)
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 0)
//
//        assertGapNotStarted()
//        assertChainTerminated(context)
//
//        waitAndAssertChainDidNotProceed(context)
//    }
//
//    func testAudioFilePreparationAction_delayDefined_contextNoLongerCurrentAfterDelay() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // Define a total delay time of 3 seconds
//        context.addGap(PlaybackGap(2, .afterTrack))
//        context.addGap(PlaybackGap(1, .beforeTrack))
//        XCTAssertEqual(context.delay!, 3)
//
//        // Mark the context as having begun execution (otherwise, playback will not proceed after the delay)
//        PlaybackRequestContext.begun(context)
//
//        action.execute(context, chain)
//
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertEqual(player.state, PlaybackState.waiting)
//        XCTAssertEqual(player.waitingCallCount, 1)
//
//        assertChainDeferred(context)
//        assertGapStarted(currentTrack, requestedTrack)
//
//        // Begin a new context to simulate a new playback request that invalidates the first context
//        let newRequestedTrack = createTrack(title: "So Far Away", duration: 275.11498984)
//        let newContext = PlaybackRequestContext(.waiting, requestedTrack, 0, newRequestedTrack, PlaybackParams.defaultParams())
//
//        PlaybackRequestContext.begun(newContext)
//        XCTAssertTrue(PlaybackRequestContext.isCurrent(newContext))
//        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
//
//        waitAndAssertChainDidNotProceed(context)
//    }
//
//    func testAudioFilePreparationAction_delayDefined_trackNeedsTranscoding_delayLongerThanTranscodingTime() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", "wma", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // Define a total delay time of 3 seconds
//        context.addGap(PlaybackGap(2, .afterTrack))
//        context.addGap(PlaybackGap(1, .beforeTrack))
//        XCTAssertEqual(context.delay!, 3)
//
//        // Mark the context as having begun execution (otherwise, playback will not proceed after the delay)
//        PlaybackRequestContext.begun(context)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.needsTranscoding)
//        XCTAssertNil(requestedTrack.lazyLoadingInfo.preparationError)
//
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
//        XCTAssertEqual(transcoder.transcodeImmediately_track, requestedTrack)
//
//        // State should be waiting, not transcoding
//        XCTAssertEqual(player.state, PlaybackState.waiting)
//        XCTAssertEqual(player.waitingCallCount, 1)
//        XCTAssertEqual(player.transcodingCallCount, 0)
//
//        assertChainDeferred(context)
//        assertGapStarted(currentTrack, requestedTrack)
//
//        // Simulate transcoding finished (before delay is over)
//        requestedTrack.prepareWithAudioFile(URL(fileURLWithPath: "/Dummy/AudioFile.m4a"))
//
//        waitAndAssertChainProceeded(context)
//        XCTAssertEqual(context.currentState, PlaybackState.waiting)
//    }
//
//    func testAudioFilePreparationAction_delayDefined_trackNeedsTranscoding_transcodingTimeLongerThanDelay() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", "wma", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // Define a total delay time of 3 seconds
//        context.addGap(PlaybackGap(2, .afterTrack))
//        context.addGap(PlaybackGap(1, .beforeTrack))
//        XCTAssertEqual(context.delay!, 3)
//
//        // Mark the context as having begun execution (otherwise, playback will not proceed after the delay)
//        PlaybackRequestContext.begun(context)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.needsTranscoding)
//        XCTAssertNil(requestedTrack.lazyLoadingInfo.preparationError)
//
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
//        XCTAssertEqual(transcoder.transcodeImmediately_track, requestedTrack)
//
//        // State should be waiting, not transcoding
//        XCTAssertEqual(player.state, PlaybackState.waiting)
//        XCTAssertEqual(player.waitingCallCount, 1)
//        XCTAssertEqual(player.transcodingCallCount, 0)
//
//        assertChainDeferred(context)
//        assertGapStarted(currentTrack, requestedTrack)
//
//        // Wait for the delay to transpire
//        executeAfter(context.delay! + 1) {
//
//            // Verify that the context current state was set to transcoding
//            XCTAssertEqual(context.currentState, PlaybackState.transcoding)
//
//            // Verify that the player is now in transcoding state
//            XCTAssertEqual(self.player.state, PlaybackState.transcoding)
//            XCTAssertEqual(self.player.transcodingCallCount, 1)
//
//            // Verify that the chain has not proceeded (because the track is still being transcoded)
//            self.assertChainDidNotProceed(context)
//        }
//    }
//
//    func testAudioFilePreparationAction_delayDefined_trackNeedsTranscoding_invalidTrack() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack("Brothers in Arms", "wma", 302.34534535, isValid: false)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // Define a total delay time of 3 seconds
//        context.addGap(PlaybackGap(2, .afterTrack))
//        context.addGap(PlaybackGap(1, .beforeTrack))
//        XCTAssertEqual(context.delay!, 3)
//
//        // Mark the context as having begun execution (otherwise, playback will not proceed after the delay)
//        PlaybackRequestContext.begun(context)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertNotNil(requestedTrack.lazyLoadingInfo.preparationError)
//        XCTAssertEqual(player.waitingCallCount, 0)
//        XCTAssertEqual(player.transcodingCallCount, 0)
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 0)
//
//        assertGapNotStarted()
//        assertChainTerminated(context)
//
//        waitAndAssertChainDidNotProceed(context)
//    }
//
//    func testAudioFilePreparationAction_noDelayDefined_trackNeedsTranscoding() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", "wma", duration: 302.34534535)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No delay defined
//        XCTAssertNil(context.delay)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertTrue(requestedTrack.lazyLoadingInfo.needsTranscoding)
//        XCTAssertNil(requestedTrack.lazyLoadingInfo.preparationError)
//        XCTAssertEqual(player.state, PlaybackState.transcoding)
//
//        assertChainDeferred(context)
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 1)
//        XCTAssertEqual(transcoder.transcodeImmediately_track, requestedTrack)
//    }
//
//    func testAudioFilePreparationAction_noDelayDefined_trackNeedsTranscoding_invalidTrack() {
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack("Brothers in Arms", "wma", 302.34534535, isValid: false)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No delay defined
//        XCTAssertNil(context.delay)
//
//        action.execute(context, chain)
//
//        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparedForPlayback)
//        XCTAssertNotNil(requestedTrack.lazyLoadingInfo.preparationError)
//        XCTAssertEqual(player.waitingCallCount, 0)
//        XCTAssertEqual(player.transcodingCallCount, 0)
//        XCTAssertEqual(transcoder.transcodeImmediatelyCallCount, 0)
//
//        assertGapNotStarted()
//        assertChainTerminated(context)
//    }
//
//    private func assertChainProceeded(_ context: PlaybackRequestContext) {
//
//        // Ensure chain proceeded
//        XCTAssertEqual(chain.proceedCount, 1)
//        XCTAssertTrue(chain.proceededContext! === context)
//        XCTAssertEqual(chain.terminationCount, 0)
//    }
//
//    private func assertChainDidNotProceed(_ context: PlaybackRequestContext) {
//
//        // Ensure chain did not proceed
//        XCTAssertEqual(chain.proceedCount, 0)
//        XCTAssertNil(chain.proceededContext)
//    }
//
//    private func assertChainDeferred(_ context: PlaybackRequestContext) {
//
//        // Ensure chain deferred (i.e. did not proceed and did not complete/terminate)
//        XCTAssertEqual(chain.proceedCount, 0)
//        XCTAssertEqual(chain.completionCount, 0)
//        XCTAssertEqual(chain.terminationCount, 0)
//    }
//
//    private func assertChainTerminated(_ context: PlaybackRequestContext) {
//
//        // Ensure chain was terminated and did not proceed
//        XCTAssertEqual(chain.terminationCount, 1)
//        XCTAssertTrue(chain.terminatedContext! === context)
//        XCTAssertEqual(chain.proceedCount, 0)
//    }
//
//    private func assertGapStarted(_ oldTrack: Track?, _ newTrack: Track) {
//
//        XCTAssertEqual(self.gapStartedMsgCount, 1)
//        XCTAssertEqual(self.gapStartedMsg_oldTrack, oldTrack)
//        XCTAssertEqual(self.gapStartedMsg_newTrack!, newTrack)
//        XCTAssertEqual(self.gapStartedMsg_endTime!.compare(Date()), ComparisonResult.orderedDescending)
//    }
//
//    private func assertGapNotStarted() {
//        XCTAssertEqual(self.gapStartedMsgCount, 0)
//    }
//
//    private func waitAndAssertChainProceeded(_ context: PlaybackRequestContext) {
//
//        executeAfter(context.delay! + 0.5) {
//            self.assertChainProceeded(context)
//        }
//    }
//
//    private func waitAndAssertChainDidNotProceed(_ context: PlaybackRequestContext) {
//
//        executeAfter(context.delay! + 0.5) {
//            self.assertChainDidNotProceed(context)
//        }
//    }
//}
