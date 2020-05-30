import XCTest

class PlaybackDelegate_Init_PlaybackProfilesTests: PlaybackDelegateTests {

    // Create a PlaybackDelegate instance with no playback profiles
    func testInit_noProfiles() {
        
        let testDelegate = PlaybackDelegate([], player, sequencer, playlist, transcoder, preferences)
        XCTAssertEqual(testDelegate.profiles.all().count, 0)
    }

    // Create a PlaybackDelegate instance with some playback profiles
    func testInit_withProfiles() {
        
        let track1 = createTrack("Strangelove", 300)
        let track2 = createTrack("Money for Nothing", 420)
        
        let profile1 = PlaybackProfile(track1.file, 102.25345345)
        let profile2 = PlaybackProfile(track2.file, 257.93487834)
        
        let profiles: [PlaybackProfile] = [profile1, profile2]
        
        let testDelegate = PlaybackDelegate(profiles, player, sequencer, playlist, transcoder, preferences)
        
        XCTAssertEqual(testDelegate.profiles.all().count, 2)
        
        let profileForTrack1 = testDelegate.profiles.get(track1)
        XCTAssertEqual(profileForTrack1!.file, track1.file)
        XCTAssertEqual(profileForTrack1!.lastPosition, profile1.lastPosition)
        
        let profileForTrack2 = testDelegate.profiles.get(track2)
        XCTAssertEqual(profileForTrack2!.file, track2.file)
        XCTAssertEqual(profileForTrack2!.lastPosition, profile2.lastPosition)
    }
}
