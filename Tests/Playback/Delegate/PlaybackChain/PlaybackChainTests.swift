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
    
    private func doTestChainConstruction(_ length: Int, _ performAssertions: Bool = true) {
        
        chain = TestablePlaybackChain()
        
        for index in 0..<length {
            
            let action = MockPlaybackChainAction()
            _ = chain.withAction(action)
            
            if performAssertions {
            
                XCTAssertEqual(chain.actions.count, index + 1)
                XCTAssertTrue((chain.actions[index] as! MockPlaybackChainAction) === action)
                
                if index > 0 {
                    
                    let previousAction = chain.actions[index - 1] as! MockPlaybackChainAction
                    XCTAssertTrue((previousAction.nextAction as! MockPlaybackChainAction) === action)
                }
            }
        }
    }
    
    func testExecute() {
        
        let track1 = createTrack("Hydropoetry Cathedra", 597)
        let track2 = createTrack("Sub-Sea Engineering", 360)
        
        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, true, PlaybackParams.defaultParams())
        
//        for numActions in [0, 1, 2, 3, 5, 10, 25, 50, 100] {
            for numActions in [1, 2, 3] {
            
            doTestChainConstruction(numActions, false)
            
            chain.execute(context)
        }
    }
    
    func createTrack(_ title: String, _ duration: Double, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        return createTrack(title, "mp3", duration, artist, album, genre)
    }
    
    func createTrack(_ title: String, _ fileExtension: String, _ duration: Double,
                     _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Dummy/%@.%@", title, fileExtension)))
        track.setPrimaryMetadata(artist, title, album, genre, duration)
        
        return track
    }
}
