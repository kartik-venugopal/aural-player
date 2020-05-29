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
    
    // MARK: playChapter() tests --------------------------------------------------------------------------------------------
    
    func testPlayChapter_noTrackPlaying() {
        
        assertNoTrack()
        
        delegate.playChapter(0)
            
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }
    
    func testPlayChapter_trackWaiting() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(track)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertWaitingTrack(track)
    }
    
    func testPlayChapter_trackTranscoding() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", "ogg", 600)
        delegate.play(track)
        assertTranscodingTrack(track)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertTranscodingTrack(track)
    }
    
    func testPlayChapter_trackPlaying_noChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testPlayChapter_trackPlaying_trackHasChapters_validIndices() {

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)

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

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)

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
    
    func testPlayChapter_trackPaused_noChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        delegate.togglePlayPause()
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.playChapter(0)
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }
    
    func testPlayChapter_trackPaused_trackHasChapters_validIndices() {

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)

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

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)

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
    
    // MARK: previousChapter() tests --------------------------------------------------------------------------------------------
    
    func testPreviousChapter_noTrackPlaying() {
        
        assertNoTrack()
        
        delegate.previousChapter()
            
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }
    
    func testPreviousChapter_trackWaiting() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(track)
        
        delegate.previousChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertWaitingTrack(track)
    }
    
    func testPreviousChapter_trackTranscoding() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", "ogg", 600)
        delegate.play(track)
        assertTranscodingTrack(track)
        
        delegate.previousChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertTranscodingTrack(track)
    }
    
    private func seekToChapter(_ index: Int) {
        
        let chapter = delegate.playingTrack!.chapters[index]
        let seekToTime = (chapter.startTime + chapter.endTime) / 2
        
        mockScheduler.seekPosition = seekToTime
    }
    
    func testPreviousChapter_trackPlaying_noChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.previousChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testPreviousChapter_trackPlaying_playingBeforeFirstChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 240, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position before the first chapter
        mockScheduler.seekPosition = 5
        
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testPreviousChapter_trackPlaying_playingFirstChapter() {

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        seekToChapter(0)
        
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testPreviousChapter_trackPlaying_playingMiddleChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        let playingChapter = 4
        seekToChapter(playingChapter)
        
        doPreviousChapter(playingChapter - 1)
    }
    
    func testPreviousChapter_trackPlaying_playingBetweenMiddleChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position between chapter 1 and 2
        mockScheduler.seekPosition = 245
        
        doPreviousChapter(1)
    }
    
    func testPreviousChapter_trackPlaying_playingLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)
        
        doPreviousChapter(lastChapterIndex - 1)
    }

    func testPreviousChapter_trackPlaying_playingAfterLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 510))
        
        track.chapters = chapters
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position after the last chapter
        mockScheduler.seekPosition = 550
        
        doPreviousChapter(track.chapters.count - 1)
    }
    
    func testPreviousChapter_trackPaused_noChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.previousChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }
    
    func testPreviousChapter_trackPaused_playingBeforeFirstChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 240, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position before the first chapter
        mockScheduler.seekPosition = 5
        
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }
    
    func testPreviousChapter_trackPaused_playingFirstChapter() {

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        seekToChapter(0)
        
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }
    
    func testPreviousChapter_trackPaused_playingMiddleChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        let playingChapter = 4
        seekToChapter(playingChapter)
        
        doPreviousChapter(playingChapter - 1)
    }
    
    func testPreviousChapter_trackPaused_playingBetweenMiddleChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position between chapter 1 and 2
        mockScheduler.seekPosition = 245
        
        doPreviousChapter(1)
    }
    
    func testPreviousChapter_trackPaused_playingLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)
        
        doPreviousChapter(lastChapterIndex - 1)
    }

    func testPreviousChapter_trackPaused_playingAfterLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 510))
        
        track.chapters = chapters
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position after the last chapter
        mockScheduler.seekPosition = 550
        
        doPreviousChapter(track.chapters.count - 1)
    }
    
    private func doPreviousChapter(_ expectedChapterIndex: Int) {
        
        let track = delegate.playingTrack!
        
        delegate.previousChapter()
        
        let startTimeOfPreviousChapter = track.chapters[expectedChapterIndex].startTime
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_time!, startTimeOfPreviousChapter, accuracy: 0.02)
        
        assertPlayingTrack(track)
    }
    
    // MARK: nextChapter() tests --------------------------------------------------------------------------------------------
    
    func testNextChapter_noTrackPlaying() {
        
        assertNoTrack()
        
        delegate.nextChapter()
            
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }
    
    func testNextChapter_trackWaiting() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        delegate.play(track, PlaybackParams.defaultParams().withDelay(5))
        assertWaitingTrack(track)
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertWaitingTrack(track)
    }
    
    func testNextChapter_trackTranscoding() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", "ogg", 600)
        delegate.play(track)
        assertTranscodingTrack(track)
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertTranscodingTrack(track)
    }
    
    func testNextChapter_trackPlaying_noChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testNextChapter_trackPlaying_playingBeforeFirstChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 240, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position before the first chapter
        mockScheduler.seekPosition = 5
        
        doNextChapter(0)
    }
    
    func testNextChapter_trackPlaying_playingFirstChapter() {

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        seekToChapter(0)
        
        doNextChapter(1)
    }
    
    func testNextChapter_trackPlaying_playingMiddleChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        let playingChapter = 4
        seekToChapter(playingChapter)
        
        doNextChapter(playingChapter + 1)
    }
    
    func testNextChapter_trackPlaying_playingBetweenMiddleChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position between chapter 1 and 2
        mockScheduler.seekPosition = 245
        
        doNextChapter(2)
    }
    
    func testNextChapter_trackPlaying_playingLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testNextChapter_trackPlaying_playingAfterLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 510))
        
        track.chapters = chapters
        
        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position after the last chapter
        mockScheduler.seekPosition = 550
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }
    
    func testNextChapter_trackPaused_noChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        XCTAssertEqual(track.chapters.count, 0)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }
    
    func testNextChapter_trackPaused_playingBeforeFirstChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 240, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position before the first chapter
        mockScheduler.seekPosition = 5
        
        doNextChapter(0)
    }
    
    func testNextChapter_trackPaused_playingFirstChapter() {

        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        seekToChapter(0)
        
        doNextChapter(1)
    }
    
    func testNextChapter_trackPaused_playingMiddleChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        let playingChapter = 4
        seekToChapter(playingChapter)
        
        doNextChapter(playingChapter + 1)
    }
    
    func testNextChapter_trackPaused_playingBetweenMiddleChapters() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 600))
        
        track.chapters = chapters
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position between chapter 1 and 2
        mockScheduler.seekPosition = 245
        
        doNextChapter(2)
    }
    
    func testNextChapter_trackPaused_playingLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        track.chapters = createChapters(10)
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)
        
        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testNextChapter_trackPaused_playingAfterLastChapter() {
        
        let track = createTrack("Eckhart Tolle - Art of Presence", 600)
        
        var chapters: [Chapter] = []
        chapters.append(Chapter("Introduction", 10, 60))
        chapters.append(Chapter("Chapter 1 - Unconsciousness", 60, 240))
        chapters.append(Chapter("Chapter 2 - Presence", 250, 510))
        
        track.chapters = chapters
        
        delegate.play(track)
        delegate.togglePlayPause()
        
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)
        
        // Seek to a position after the last chapter
        mockScheduler.seekPosition = 550
        
        delegate.nextChapter()
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }
    
    private func doNextChapter(_ expectedChapterIndex: Int) {
        
        let track = delegate.playingTrack!
        
        delegate.nextChapter()
        
        let startTimeOfNextChapter = track.chapters[expectedChapterIndex].startTime
        
        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_time!, startTimeOfNextChapter, accuracy: 0.02)
        
        assertPlayingTrack(track)
    }
}
