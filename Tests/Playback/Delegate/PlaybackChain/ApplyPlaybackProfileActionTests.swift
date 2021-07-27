//
//  ApplyPlaybackProfileActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

//class ApplyPlaybackProfileActionTests: AuralTestCase {
//
//    var action: ApplyPlaybackProfileAction!
//    var profiles: PlaybackProfiles!
//    var preferences: PlaybackPreferences!
//
//    var chain: MockPlaybackChain!
//
//    override func setUp() {
//
//        profiles = PlaybackProfiles()
//        preferences = PlaybackPreferences([:])
//
//        action = ApplyPlaybackProfileAction(profiles, preferences)
//        chain = MockPlaybackChain()
//    }
//
//    func testApplyPlaybackProfileAction_dontRememberPosition() {
//
//        preferences.rememberLastPosition = false
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        profiles[requestedTrack, PlaybackProfile(requestedTrack] = 101.2131234)
//        XCTAssertNotNil(profiles[requestedTrack])
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No start position specified in request params
//        XCTAssertNil(context.requestParams.startPosition)
//
//        action.execute(context, chain)
//
//        // No profile should have been applied, because the preference is set to don't remember.
//        XCTAssertNil(context.requestParams.startPosition)
//
//        XCTAssertEqual(chain.proceedCount, 1)
//        XCTAssertTrue(chain.proceededContext! === context)
//    }
//
//    func testApplyPlaybackProfileAction_noProfileForRequestedTrack() {
//
//        preferences.rememberLastPosition = true
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        // Assert no profile exists for requested track
//        XCTAssertNil(profiles[requestedTrack])
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No start position specified in request params
//        XCTAssertNil(context.requestParams.startPosition)
//
//        action.execute(context, chain)
//
//        // No profile should have been applied, because there is no profile for the requested track.
//        XCTAssertNil(context.requestParams.startPosition)
//
//        XCTAssertEqual(chain.proceedCount, 1)
//        XCTAssertTrue(chain.proceededContext! === context)
//    }
//
//    func testApplyPlaybackProfileAction_startPositionSpecifiedInParams() {
//
//        preferences.rememberLastPosition = true
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        // Create a profile for the requested track
//        profiles[requestedTrack, PlaybackProfile(requestedTrack] = 101.2131234)
//        XCTAssertNotNil(profiles[requestedTrack])
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams().withStartPosition(55.6789))
//
//        let startPositionBeforeActionExecution = context.requestParams.startPosition
//        XCTAssertNotNil(startPositionBeforeActionExecution)
//
//        action.execute(context, chain)
//
//        // No profile should have been applied, because a specific start position
//        // has been specified in the request params.
//        XCTAssertEqual(context.requestParams.startPosition!, startPositionBeforeActionExecution!, accuracy: 0.001)
//
//        XCTAssertEqual(chain.proceedCount, 1)
//        XCTAssertTrue(chain.proceededContext! === context)
//    }
//
//    func testApplyPlaybackProfileAction_remember_profilePositionEqualToDuration_resetTo0() {
//
//        preferences.rememberLastPosition = true
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        // Create a profile for the requested track
//        let profile = PlaybackProfile(requestedTrack, requestedTrack.duration)
//        profiles[requestedTrack] = profile
//        XCTAssertEqual(profiles[requestedTrack]!.lastPosition, profile.lastPosition)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No start position specified in request params
//        XCTAssertNil(context.requestParams.startPosition)
//
//        action.execute(context, chain)
//
//        // The profile should have been applied by the action (position reset to 0)
//        XCTAssertEqual(context.requestParams.startPosition!, 0)
//
//        XCTAssertEqual(chain.proceedCount, 1)
//        XCTAssertTrue(chain.proceededContext! === context)
//    }
//
//    func testApplyPlaybackProfileAction_remember_profileApplied() {
//
//        preferences.rememberLastPosition = true
//
//        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
//
//        // Create a profile for the requested track
//        let profile = PlaybackProfile(requestedTrack, 101.2131234)
//        profiles[requestedTrack] = profile
//        XCTAssertEqual(profiles[requestedTrack]!.lastPosition, profile.lastPosition)
//
//        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
//
//        // No start position specified in request params
//        XCTAssertNil(context.requestParams.startPosition)
//
//        action.execute(context, chain)
//
//        // The profile should have been applied by the action
//        XCTAssertEqual(context.requestParams.startPosition!, profile.lastPosition, accuracy: 0.001)
//
//        XCTAssertEqual(chain.proceedCount, 1)
//        XCTAssertTrue(chain.proceededContext! === context)
//    }
//}
