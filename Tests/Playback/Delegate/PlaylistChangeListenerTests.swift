import XCTest

class PlaylistChangeListenerTests: PlaybackDelegateTests {
    
    func testTracksRemoved_noTrack() {
        
        assertNoTrack()
        
        delegate.tracksRemoved(TrackRemovalResults.empty)
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        assertNoTrack()
    }

    func testTracksRemoved_trackPlaying_playingTrackNotRemoved() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        assertPlayingTrack(someTrack)
        
        delegate.tracksRemoved(TrackRemovalResults.empty)
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        assertPlayingTrack(someTrack)
    }
    
    func testTracksRemoved_trackPlaying_playingTrackRemoved() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        assertPlayingTrack(someTrack)
        
        delegate.tracksRemoved(TrackRemovalResults.empty)
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        assertNoTrack()
    }
    
    func testTracksRemoved_trackWaiting_playingTrackRemoved() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlaybackWithDelay(someTrack, 3)
        assertWaitingTrack(someTrack)
        
        delegate.tracksRemoved(TrackRemovalResults.empty)
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        assertNoTrack()
    }
    
    func testTracksRemoved_trackTranscoding_playingTrackRemoved() {
        
        let someTrack = createTrack("SomeTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(someTrack)
        assertTranscodingTrack(someTrack)
        
        delegate.tracksRemoved(TrackRemovalResults.empty)
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        assertNoTrack()
    }
    
    func testPlaylistCleared_noTrack() {
        
        assertNoTrack()
        
        delegate.playlistCleared()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        assertNoTrack()
    }
    
    func testPlaylistCleared_trackPlaying() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlayback(someTrack)
        assertPlayingTrack(someTrack)
        
        delegate.playlistCleared()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        assertNoTrack()
    }
    
    func testPlaylistCleared_trackWaiting() {
        
        let someTrack = createTrack("SomeTrack", 300)
        doBeginPlaybackWithDelay(someTrack, 3)
        assertWaitingTrack(someTrack)
        
        delegate.playlistCleared()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        assertNoTrack()
    }
    
    func testPlaylistCleared_trackTranscoding() {
        
        let someTrack = createTrack("SomeTrack", "wma", 300)
        doBeginPlayback_trackNeedsTranscoding(someTrack)
        assertTranscodingTrack(someTrack)
        
        delegate.playlistCleared()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        assertNoTrack()
    }
}
