import XCTest

class PlaybackDelegateTogglePlayPauseTests: PlaybackDelegateTests {

    func testTogglePlayPause_noTrack_emptyPlaylist() {
        
        setup_emptyPlaylist_noPlayingTrack()
        
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertNil(delegate.playingTrack)
        XCTAssertNil(delegate.waitingTrack)
    }
    
    func testTogglePlayPause_noTrack_playbackBegins() {
        
        setup_emptyPlaylist_noPlayingTrack()
        
        createTracks(10)
        
        delegate.togglePlayPause()
        
        XCTAssertEqual(delegate.state, PlaybackState.playing)
        XCTAssertNotNil(delegate.playingTrack)
        XCTAssertNil(delegate.waitingTrack)
    }
}
