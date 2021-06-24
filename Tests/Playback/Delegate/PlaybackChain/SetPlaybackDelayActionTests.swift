//
//  SetPlaybackDelayActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SetPlaybackDelayActionTests: AuralTestCase {
    
    var action: SetPlaybackDelayAction!
    var playlist: TestablePlaylist!
    
    var chain: MockPlaybackChain!

    override func setUp() {
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = TestablePlaylist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        action = SetPlaybackDelayAction(playlist)
        chain = MockPlaybackChain()
    }

    func testSetPlaybackDelayAction_noRequestedTrack() {
        
        // Create a context with no requested track
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, nil, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        // Ensure no delay was set in the context
        XCTAssertNil(context.delay)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainTerminated(context)
    }
    
    // When playing a history/bookmark/favorite track
    func testSetPlaybackDelayAction_dontAllowDelay() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams().withAllowDelay(false))
        
        action.execute(context, chain)
        
        // Ensure no delay was set in the context
        XCTAssertNil(context.delay)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
   
    // When user requests track to be played after a set delay
    func testSetPlaybackDelayAction_gapAfterCompletedTrack_delayDefinedInParams() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams().withDelay(5)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap to the context to simulate a gap after the completed track.
        // This gap should be removed (ignored) by the action and replaced with the delay defined in the request params.
        context.addGap(PlaybackGap(10, .afterTrack))
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, requestParams.delay!)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    // When user requests track to be played after a set delay
    func testSetPlaybackDelayAction_gapBeforeRequestedTrack_delayDefinedInParams() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams().withDelay(5)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap before the requested track (this gap should be ignored by the action
        // and the delay defined in the request params should be used.
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .persistent)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, requestParams.delay!)
        
        // Ensure no calls to playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    // When user requests track to be played after a set delay
    func testSetPlaybackDelayAction_gapAfterCompletedTrack_gapBeforeRequestedTrack_delayDefinedInParams() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams().withDelay(5)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap to the context to simulate a gap after the completed track.
        // This gap should be removed (ignored) by the action and replaced with the delay defined in the request params.
        context.addGap(PlaybackGap(10, .afterTrack))
        
        // Add a gap before the requested track (this gap should be ignored by the action
        // and the delay defined in the request params should be used.
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .persistent)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, requestParams.delay!)
        
        // Ensure no calls to playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testSetPlaybackDelayAction_gapBeforeRequestedTrack_persistentGap() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams()
        XCTAssertNil(requestParams.delay)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap before the requested track
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .persistent)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Verify calls to the playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testSetPlaybackDelayAction_gapAfterCompletedTrack_gapBeforeRequestedTrack() {
        
        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams()
        XCTAssertNil(requestParams.delay)
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, requestedTrack, requestParams)
        
        // Add a gap to the context to simulate a gap after the completed track.
        let gapAfterCompletedTrack = PlaybackGap(5, .afterTrack, .persistent)
        context.addGap(gapAfterCompletedTrack)
        
        // Add a gap before the requested track
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .persistent)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapAfterCompletedTrack.duration + gapBeforeRequestedTrack.duration)
        
        // Verify calls to the playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testSetPlaybackDelayAction_gapBetweenTracks_gapBeforeRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams()
        XCTAssertNil(requestParams.delay)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap to the context to simulate a gap between tracks defined through preferences (i.e. implicit gap).
        // This gap should be ignored.
        let gapBetweenTracks = PlaybackGap(5, .afterTrack, .implicit)
        context.addGap(gapBetweenTracks)
        
        // Add a gap before the requested track (this should take precedence over the previously defined implicit gap).
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .persistent)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Verify calls to the playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testSetPlaybackDelayAction_gapBeforeRequestedTrack_gapPersistsTillAppExits() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams()
        XCTAssertNil(requestParams.delay)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap before the requested track
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .tillAppExits)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Verify calls to the playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testSetPlaybackDelayAction_gapBeforeRequestedTrack_oneTimeGap() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams()
        XCTAssertNil(requestParams.delay)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap before the requested track (this gap should be removed by the action as it is only
        // valid as a one time occurrence)
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .oneTime)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Ensure that the one time gap was removed from the playlist
        XCTAssertNil(playlist.getGapBeforeTrack(requestedTrack))
        
        // Verify calls to the playlist (by the action)
        XCTAssertEqual(playlist.removeGapForTrackCallCounts[requestedTrack]![.beforeTrack], 1)
        
        assertChainProceeded(context)
    }
    
    // A one-time gap is defined before the requested track (in the playlist) AND
    // a delay is defined in the request params. The request params delay should take
    // precedence and the one-time gap should remain as is (should not be deleted).
    func testSetPlaybackDelayAction_oneTimeGap_delayDefinedInParams_gapNotRemoved() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let requestParams = PlaybackParams.defaultParams().withDelay(5)
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // Add a gap before the requested track (this gap should be removed by the action as it is only
        // valid as a one time occurrence)
        let gapBeforeRequestedTrack = PlaybackGap(10, .beforeTrack, .oneTime)
        playlist.setGapsForTrack(requestedTrack, gapBeforeRequestedTrack, nil)
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, requestParams.delay!)
        
        // Ensure that the one time gap was NOT removed from the playlist
        XCTAssertTrue(playlist.getGapBeforeTrack(requestedTrack)! === gapBeforeRequestedTrack)
        
        // Verify calls to the playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testSetPlaybackDelayAction_noDelayInRequestParams_noGap() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        // No delay defined in request params
        let requestParams = PlaybackParams.defaultParams()
        XCTAssertNil(requestParams.delay)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, requestParams)
        
        // No playlist gaps before requested track
        XCTAssertNil(playlist.getGapBeforeTrack(requestedTrack))
        
        action.execute(context, chain)
        
        // Ensure that no delay was set in the context
        XCTAssertNil(context.delay)
        
        // Verify calls to the playlist (by the action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    private func assertChainProceeded(_ context: PlaybackRequestContext) {
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
    
    private func assertChainTerminated(_ context: PlaybackRequestContext) {
        
        // Ensure chain was terminated and did not proceed
        XCTAssertEqual(chain.terminationCount, 1)
        XCTAssertTrue(chain.terminatedContext! === context)
        XCTAssertEqual(chain.proceedCount, 0)
    }
}
