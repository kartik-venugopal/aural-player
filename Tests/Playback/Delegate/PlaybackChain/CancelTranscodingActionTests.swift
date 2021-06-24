//
//  CancelTranscodingActionTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class CancelTranscodingActionTests: AuralTestCase {

    var action: CancelTranscodingAction!
    var chain: MockPlaybackChain!
    
    var transcoder: MockTranscoder!
    
    override func setUp() {
        
        transcoder = MockTranscoder()
        action = CancelTranscodingAction(transcoder)
        chain = MockPlaybackChain()
    }
    
    func testCancelTranscodingAction_noCurrentTrack_noRequestedTrack() {
        
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_noCurrentTrack_hasRequestedTrack() {
        
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.noTrack, nil, 0, requestedTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackTranscoding_noRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, nil, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 1)
    }
    
    func testCancelTranscodingAction_trackTranscoding_requestedTrackDifferent() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 1)
    }
    
    func testCancelTranscodingAction_trackTranscoding_requestedTrackSame() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.transcoding, currentTrack, 0, currentTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackPlaying() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.playing, currentTrack, 304.3425435, requestedTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackPaused() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.paused, currentTrack, 304.3425435, requestedTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    func testCancelTranscodingAction_trackWaiting() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Sub-Sea Engineering", 360)
        let context = PlaybackRequestContext(.waiting, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        doTestCancelTranscodingAction(context, 0)
    }
    
    private func doTestCancelTranscodingAction(_ context: PlaybackRequestContext, _ expectedTranscoderCancelCallCount: Int) {
        
        action.execute(context, chain)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, expectedTranscoderCancelCallCount)
        XCTAssertEqual(transcoder.transcodeCancel_track, expectedTranscoderCancelCallCount == 0 ? nil : context.currentTrack!)
        
        // Ensure the chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
}
