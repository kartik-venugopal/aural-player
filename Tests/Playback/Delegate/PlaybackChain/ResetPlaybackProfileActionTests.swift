import XCTest

class ResetPlaybackProfileActionTests: AuralTestCase {

    var profiles: PlaybackProfiles!
    
    var action: ResetPlaybackProfileAction!
    var chain: MockPlaybackChain!
    
    override func setUp() {
        
        profiles = PlaybackProfiles()
        action = ResetPlaybackProfileAction(profiles)
        
        chain = MockPlaybackChain()
    }
    
    func testResetPlaybackProfileAction_noProfileForCompletedTrack() {
        
        let completedTrack = createTrack("Favriel", 165)
        let nextTrack = createTrack("Heartbeats", 189)
        
        let someOtherTrack = createTrack("Like Ice", 243)
        
        // Ensure no profile exists for completed track
        profiles.add(someOtherTrack.file, PlaybackProfile(someOtherTrack.file, 59.769487))
        XCTAssertNil(profiles.get(completedTrack))
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nextTrack, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        XCTAssertNil(profiles.get(completedTrack))
        
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
    
    func testResetPlaybackProfileAction_completedTrackHasProfile() {
        
        let completedTrack = createTrack("Favriel", 165)
        let nextTrack = createTrack("Heartbeats", 189)
        
        // Ensure that a profile exists for completed track
        let completedTrackProfile = PlaybackProfile(completedTrack.file, 101.2324899435)
        profiles.add(completedTrack.file, completedTrackProfile)
        
        XCTAssertTrue(profiles.get(completedTrack)! === completedTrackProfile)
        XCTAssertEqual(profiles.get(completedTrack)!.lastPosition, completedTrackProfile.lastPosition, accuracy: 0.001)
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nextTrack, PlaybackParams.defaultParams())
        
        action.execute(context, chain)
        
        // Ensure that the profile's last position has been reset to 0
        let updatedProfileForCompletedTrack = profiles.get(completedTrack)
        XCTAssertNotNil(updatedProfileForCompletedTrack)
        XCTAssertEqual(updatedProfileForCompletedTrack!.lastPosition, 0)
        
        // Ensure the chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
}
