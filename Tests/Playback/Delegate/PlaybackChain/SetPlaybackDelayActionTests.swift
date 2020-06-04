import XCTest

class SetPlaybackDelayActionTests: AuralTestCase {
    
    var action: SetPlaybackDelayAction!
    var playlist: TestablePlaylist!
    
    var chain: MockPlaybackChain!

    override func setUp() {
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists, .artist)
        let albumsPlaylist = GroupingPlaylist(.albums, .album)
        let genresPlaylist = GroupingPlaylist(.genres, .genre)
        
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
        
        // Ensure chain was terminated and did not proceed
        XCTAssertEqual(chain.terminationCount, 1)
        XCTAssertTrue(chain.terminatedContext! === context)
        XCTAssertEqual(chain.proceedCount, 0)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.getGapBeforeCallCounts.isEmpty)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
    }
    
    // When playing a history/bookmark/favorite track
    func testSetPlaybackDelayAction_dontAllowDelay() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams().withAllowDelay(false))
        
        action.execute(context, chain)
        
        // Ensure no delay was set in the context
        XCTAssertNil(context.delay)
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.getGapBeforeCallCounts.isEmpty)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
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
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.getGapBeforeCallCounts.isEmpty)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
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
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Ensure no calls to playlist (by the action)
        XCTAssertTrue(playlist.getGapBeforeCallCounts.isEmpty)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
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
        XCTAssertEqual(playlist.setGapsForTrackCallCounts[requestedTrack], 1)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Verify calls to the playlist (by the action)
        XCTAssertEqual(playlist.getGapBeforeCallCounts[requestedTrack], 1)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
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
        XCTAssertEqual(playlist.setGapsForTrackCallCounts[requestedTrack], 1)
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Verify calls to the playlist (by the action)
        XCTAssertEqual(playlist.getGapBeforeCallCounts[requestedTrack], 1)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
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
        
        action.execute(context, chain)
        
        // Ensure the right delay was set in the context
        XCTAssertEqual(context.delay!, gapBeforeRequestedTrack.duration)
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Verify calls to the playlist (by the action)
        XCTAssertEqual(playlist.getGapBeforeCallCounts[requestedTrack], 1)
        XCTAssertEqual(playlist.removeGapForTrackCallCounts[requestedTrack]![.beforeTrack], 1)
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
        XCTAssertEqual(playlist.getGapBeforeCallCounts[requestedTrack], 1)
        
        action.execute(context, chain)
        
        // Ensure that no delay was set in the context
        XCTAssertNil(context.delay)
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
        
        // Verify calls to the playlist (by the action)
        XCTAssertEqual(playlist.getGapBeforeCallCounts[requestedTrack], 2)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
    }
}
