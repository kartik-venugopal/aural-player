import XCTest

class PlaylistChangeListenerTests: PlaybackDelegateTests {

    func testTracksRemoved_playingTrackNotRemoved() {
        
        delegate.tracksRemoved(TrackRemovalResults.empty, false, nil)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
    }
    
    func testTracksRemoved_playingTrackRemoved() {
        
        delegate.tracksRemoved(TrackRemovalResults.empty, true, createTrack("Hydropoetry Cathedra", 597))
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
    }
    
    func testPlaylistCleared() {
        
        delegate.playlistCleared()
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
    }
}
