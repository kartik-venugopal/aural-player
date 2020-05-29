import XCTest

class PlaybackDelegate_ChapterPlaybackTests: PlaybackDelegateTests {

    // TODO: Performance tests (seek timer task to poll playingChapter) ... playingChapter performance has to be tested.
    
    private func createChapters(_ count: Int) -> [Chapter] {
        
        var chapters: [Chapter] = []
        
        var curTime: Double = 0
        let duration: Double = 60  // 1 minute
        
        for index in 0..<count {
            
            chapters.append(Chapter(String(format: "Chapter %d", index), curTime, curTime + duration))
            curTime += duration
        }
        
        return chapters
    }
    
    func testPlayChapter_noTrackPlaying() {
        
        assertNoTrack()
        
        delegate.playChapter(0)
            
        assertNoTrack()
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
    }
    
    func testPlayChapter_trackWaiting() {
        
        let track = createTrack("Ayyappa", 600)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(track)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertWaitingTrack(track)
    }
    
    func testPlayChapter_trackTranscoding() {
        
        let track = createTrack("Ayyappa", "ogg", 600)
        delegate.play(track)
        assertTranscodingTrack(track)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertTranscodingTrack(track)
    }
    
    func testPlayChapter_trackPlaying_noChapters() {
        
        let track = createTrack("Ayyappa", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testPlayChapter_trackPlaying_trackHasChapters_validIndices() {

        let track = createTrack("Ayyappa", 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)

        // Valid indices

        for chapterIndex in 0..<chapterCount {

            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, chapterIndex + 1)
            XCTAssertEqual(player.forceSeekToTime_time!, track.chapters[chapterIndex].startTime, accuracy: 0.02)
            assertPlayingTrack(track)
        }
    }

    func testPlayChapter_trackPlaying_trackHasChapters_invalidIndices() {

        let track = createTrack("Ayyappa", 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)

        // Invalid indices

        for chapterIndex in chapterCount...(chapterCount + 5) {

            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
            assertPlayingTrack(track)
        }
    }
    
    func testPlayChapter_trackPaused_trackHasChapters_validIndices() {

        let track = createTrack("Ayyappa", 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)
        
        delegate.togglePlayPause()
        assertPausedTrack(track)

        // Valid indices

        for chapterIndex in 0..<chapterCount {

            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, chapterIndex + 1)
            XCTAssertEqual(player.forceSeekToTime_time!, track.chapters[chapterIndex].startTime, accuracy: 0.02)
            assertPlayingTrack(track)
        }
    }

    func testPlayChapter_trackPaused_trackHasChapters_invalidIndices() {

        let track = createTrack("Ayyappa", 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)
        
        delegate.togglePlayPause()
        assertPausedTrack(track)

        // Invalid indices

        for chapterIndex in chapterCount...(chapterCount + 5) {

            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
            assertPausedTrack(track)
        }
    }
}
