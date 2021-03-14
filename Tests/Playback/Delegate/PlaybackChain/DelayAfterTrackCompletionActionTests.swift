import XCTest

class DelayAfterTrackCompletionActionTests: AuralTestCase {
    
    var action: DelayAfterTrackCompletionAction!
    
    var playlist: TestablePlaylist!
    var sequencer: MockSequencer!
    var preferences: PlaybackPreferences!
    
    var chain: MockPlaybackChain!

    override func setUp() {
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = TestablePlaylist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        sequencer = MockSequencer()
        preferences = PlaybackPreferences([:])
        
        action = DelayAfterTrackCompletionAction(playlist, sequencer, preferences)
        chain = MockPlaybackChain()
    }
    
    func testDelayAfterTrackCompletionAction_noCompletedTrack() {
        
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
        
        // Gap between tracks should be ignored
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 5
        
        action.execute(context, chain)
        
        // When there is no completed track, no delay should have been set
        XCTAssertNil(context.delay)
        
        // Ensure no calls to playlist
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_noSubsequentTrack() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        sequencer.subsequentTrack = nil

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // Gap defined in playlist should be ignored
        let gapAfterCompletedTrack = PlaybackGap(5, .afterTrack, .persistent)
        playlist.setGapsForTrack(completedTrack, nil, gapAfterCompletedTrack)
        XCTAssertTrue(playlist.getGapAfterTrack(completedTrack)! === gapAfterCompletedTrack)

        action.execute(context, chain)

        // When there is no subsequent track, no delay should have been set
        XCTAssertNil(context.delay)
        
        // Ensure no calls to playlist (by action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_noGaps() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // No gap defined in playlist
        XCTAssertNil(playlist.getGapAfterTrack(completedTrack))
        
        // No gap defined in preferences
        preferences.gapBetweenTracks = false
        
        action.execute(context, chain)

        // Delay should equal gap duration
        XCTAssertNil(context.delay)
        
        // Verify calls to playlist (by action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_gapAfterCompletedTrack_persistentGap() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // Gap defined in playlist should be used to set delay
        let gapAfterCompletedTrack = PlaybackGap(5, .afterTrack, .persistent)
        playlist.setGapsForTrack(completedTrack, nil, gapAfterCompletedTrack)
        XCTAssertTrue(playlist.getGapAfterTrack(completedTrack)! === gapAfterCompletedTrack)

        action.execute(context, chain)

        // Delay should equal gap duration
        XCTAssertEqual(context.delay!, gapAfterCompletedTrack.duration)
        
        // Verify calls to playlist (by action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_gapAfterCompletedTrack_gapPersistsTillAppExists() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // Gap defined in playlist should be used to set delay
        let gapAfterCompletedTrack = PlaybackGap(5, .afterTrack, .tillAppExits)
        playlist.setGapsForTrack(completedTrack, nil, gapAfterCompletedTrack)
        XCTAssertTrue(playlist.getGapAfterTrack(completedTrack)! === gapAfterCompletedTrack)

        action.execute(context, chain)

        // Delay should equal gap duration
        XCTAssertEqual(context.delay!, gapAfterCompletedTrack.duration)
        
        // Verify calls to playlist (by action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_gapAfterCompletedTrack_oneTimeGap() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // Gap defined in playlist should be used to set delay
        let gapAfterCompletedTrack = PlaybackGap(5, .afterTrack, .oneTime)
        playlist.setGapsForTrack(completedTrack, nil, gapAfterCompletedTrack)
        XCTAssertTrue(playlist.getGapAfterTrack(completedTrack)! === gapAfterCompletedTrack)
        
        action.execute(context, chain)

        // Delay should equal gap duration
        XCTAssertEqual(context.delay!, gapAfterCompletedTrack.duration)
        
        // Ensure that the one-time gap was removed from the playlist.
        XCTAssertNil(playlist.getGapAfterTrack(completedTrack))
        
        // Verify calls to playlist (by action)
        XCTAssertEqual(playlist.removeGapForTrackCallCounts[completedTrack]![.afterTrack]!, 1)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_gapBetweenTracks() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // Gap defined in preferences should be used to set the delay
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 5
        
        action.execute(context, chain)

        // Delay should equal gap duration
        XCTAssertEqual(context.delay!, Double(preferences.gapBetweenTracksDuration))
        
        // Verify calls to playlist (by action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    func testDelayAfterTrackCompletionAction_gapAfterCompletedTrack_gapBetweenTracks() {

        let completedTrack = createTrack("Hydropoetry Cathedra", 597)
        let subsequentTrack = createTrack("Brothers in Arms", 302.34534535)
        sequencer.subsequentTrack = subsequentTrack

        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        // Gap defined in playlist should be used to set delay
        let gapAfterCompletedTrack = PlaybackGap(5, .afterTrack, .persistent)
        playlist.setGapsForTrack(completedTrack, nil, gapAfterCompletedTrack)
        XCTAssertTrue(playlist.getGapAfterTrack(completedTrack)! === gapAfterCompletedTrack)
        
        // Gap defined in preferences should be ignored (playlist gaps take precedence)
        preferences.gapBetweenTracks = true
        preferences.gapBetweenTracksDuration = 5

        action.execute(context, chain)

        // Delay should equal gap duration
        XCTAssertEqual(context.delay!, gapAfterCompletedTrack.duration)
        
        // Verify calls to playlist (by action)
        XCTAssertTrue(playlist.removeGapForTrackCallCounts.isEmpty)
        
        assertChainProceeded(context)
    }
    
    private func assertChainProceeded(_ context: PlaybackRequestContext) {
        
        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
}
