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

class AudioFilePreparationActionTests: AuralTestCase {

    var action: AudioFilePreparationAction!
    var chain: MockPlaybackChain!

    var trackReader: MockTrackReader!
    
    override func setUp() {

        trackReader = MockTrackReader()
        action = AudioFilePreparationAction(trackReader: trackReader)
        chain = MockPlaybackChain()

        PlaybackRequestContext.clearCurrentContext()
    }

    func testAudioFilePreparationAction_noRequestedTrack() {

        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams())

        action.execute(context, chain)

        assertChainTerminated(context, error: NoRequestedTrackError.instance)
    }

    func testAudioFilePreparationAction() {

        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)

        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())

        action.execute(context, chain)

        XCTAssertFalse(requestedTrack.preparationFailed)
        XCTAssertNotNil(requestedTrack.playbackContext)

        assertChainProceeded(context)
    }

    func testAudioFilePreparationAction_invalidTrack() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Brothers in Arms", duration: 302.34534535)
        
        // Simulate an error generated when preparing the track for playback.
        let preparationError = NoAudioTracksError(requestedTrack.file)
        trackReader.preparationError = preparationError

        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())

        action.execute(context, chain)

        XCTAssertNil(requestedTrack.playbackContext)
        assertChainTerminated(context, error: preparationError)
    }

    private func assertChainProceeded(_ context: PlaybackRequestContext) {

        // Ensure chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }

    private func assertChainTerminated(_ context: PlaybackRequestContext, error: DisplayableError) {

        // Ensure chain was terminated and did not proceed
        XCTAssertEqual(chain.terminationCount, 1)
        XCTAssertTrue(chain.terminatedContext === context)
        XCTAssertTrue(chain.terminationError === error)
        XCTAssertEqual(chain.proceedCount, 0)
    }
}
