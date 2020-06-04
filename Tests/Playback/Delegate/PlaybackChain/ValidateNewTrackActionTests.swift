import XCTest

class ValidateNewTrackActionTests: AuralTestCase {

    var action: ValidateNewTrackAction!
    var chain: MockPlaybackChain!
    
    override func setUp() {
        
        action = ValidateNewTrackAction()
        chain = MockPlaybackChain()
    }
    
    func testValidateNewTrackAction_noRequestedTrack() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let context = PlaybackRequestContext(.playing, currentTrack, 0, nil, PlaybackParams.defaultParams())
        
        // Begin the context
        PlaybackRequestContext.begun(context)
        
        action.execute(context, chain)

        // Ensure the chain was terminated
        XCTAssertEqual(chain.terminationCount, 1)
        XCTAssertTrue(chain.terminatedContext! === context)
        XCTAssertEqual(chain.proceedCount, 0)
    }
    
    func testValidateNewTrackAction_trackIsValid() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535, isValid: true)
        
        let context = PlaybackRequestContext(.playing, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.validated)
        XCTAssertFalse(requestedTrack.lazyLoadingInfo.preparationFailed)
        XCTAssertNil(requestedTrack.lazyLoadingInfo.preparationError)
        
        // Ensure the chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
    
    func testValidateNewTrackAction_trackIsInvalid() {
        
        let currentTrack = createTrack("Hydropoetry Cathedra", 597)
        let requestedTrack = createTrack("Brothers in Arms", 302.34534535, isValid: false)
        
        let context = PlaybackRequestContext(.playing, currentTrack, 0, requestedTrack, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.validated)
        XCTAssertTrue(requestedTrack.lazyLoadingInfo.preparationFailed)
        XCTAssertNotNil(requestedTrack.lazyLoadingInfo.preparationError)

        // Ensure the chain was terminated
        XCTAssertEqual(chain.terminationCount, 1)
        XCTAssertTrue(chain.terminatedContext! === context)
        XCTAssertEqual(chain.proceedCount, 0)
    }
}
