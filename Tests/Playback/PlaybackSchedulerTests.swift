import XCTest
import Cocoa

class PlaybackSchedulerTests: AuralTestCase, NotificationSubscriber {
    
    private var scheduler: PlaybackScheduler!
    private var mockPlayerNode: MockPlayerNode!
    
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path"))
    
    var trackCompletionMsgReceived: Bool = false
    var completedSessionIsCurrent: Bool = false

    override func setUp() {
        
        // This will be done only once
        if scheduler == nil {
            
            mockPlayerNode = MockPlayerNode(useLegacyAPI: false)
            scheduler = PlaybackScheduler(mockPlayerNode)
            
            Messenger.subscribe(self, .player_trackPlaybackCompleted, self.trackPlaybackCompleted(_:))
        }
        
        track.setDuration(300)
        
        mockPlayerNode.resetMock()
        
        trackCompletionMsgReceived = false
        completedSessionIsCurrent = false
        
        _ = PlaybackSession.endCurrent()
        
        XCTAssertNil(PlaybackSession.currentSession)
        XCTAssertFalse(mockPlayerNode.played || mockPlayerNode.paused || mockPlayerNode.stopped || mockPlayerNode.isPlaying)
    }
    
    override func tearDown() {

        // Prevent test case objects from receiving each other's messages.
        Messenger.unsubscribeAll(for: self)
    }
    
    func trackPlaybackCompleted(_ completedSession: PlaybackSession) {

        trackCompletionMsgReceived = true
        completedSessionIsCurrent = PlaybackSession.isCurrent(completedSession)
    }
    
    // MARK: seekPosition tests ---------------------------------------------------------------------------------------------------------
    
    private func doTestSeekPosition(_ hasCurrentSession: Bool, _ playing: Bool, _ loop: PlaybackLoop?, _ playerNodeSeekPosition: Double, _ expectedSeekPosition: Double) {
        
        if hasCurrentSession {
            _ = PlaybackSession.start(track)
        }
        
        if playing {
            mockPlayerNode.play()
        }
        
        if let theLoop = loop {

            PlaybackSession.beginLoop(theLoop.startTime)
            if let endTime = theLoop.endTime {PlaybackSession.endLoop(endTime)}
        }
        
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)
        
        XCTAssertEqual(PlaybackSession.hasCurrentSession(), hasCurrentSession)
        
        mockPlayerNode._seekPosition = playerNodeSeekPosition
        
        XCTAssertEqual(scheduler.seekPosition, expectedSeekPosition)
    }
    
    func testSeekPosition_noCurrentSession() {
        doTestSeekPosition(false, false, nil, 25, 0)
    }
    
    func testSeekPosition_playing_validNodePosition() {
        
        for _ in 1...100000 {
            
            let seekPos = Double.random(in: 0...300)
            doTestSeekPosition(true, true, nil, seekPos, seekPos)
        }
    }
    
    // Test correction logic (seek pos <= track duration).
    func testSeekPosition_playing_nodePositionLessThan0() {
        
        for _ in 1...100000 {
            
            let seekPos = Double.random(in: -100..<0)
            doTestSeekPosition(true, true, nil, seekPos, 0)
        }
    }
    
    // Test correction logic (seek pos <= track duration).
    func testSeekPosition_playing_nodePositionGreaterThanDuration() {
        
        for _ in 1...100000 {
            
            let seekPos = Double.random(in: track.duration...(track.duration + 10))
            doTestSeekPosition(true, true, nil, seekPos, track.duration)
        }
    }
    
    // Test correction logic (seek pos <= track duration).
    func testSeekPosition_playing_completeLoop_nodePositionLessThanLoopStartTime() {
        
        let loop = PlaybackLoop(10, 25)
        
        for _ in 1...100000 {
            
            let seekPos = Double.random(in: 0..<loop.startTime)
            doTestSeekPosition(true, true, loop, seekPos, loop.startTime)
        }
    }
    
    // Test correction logic (seek pos <= loop end time).
    func testSeekPosition_playing_completeLoop_nodePositionGreaterThanLoopEndTime() {
        
        let loop = PlaybackLoop(10, 25)
        
        for _ in 1...100000 {
            
            let seekPos = Double.random(in: loop.endTime!..<(loop.endTime! + 1))
            doTestSeekPosition(true, true, loop, seekPos, loop.endTime!)
        }
    }
    
    // Test correction logic (seek pos <= track duration).
    func testSeekPosition_playing_incompleteLoop_nodePositionLessThanLoopStartTime() {
        doTestSeekPosition(true, true, PlaybackLoop(10), 9.98, 10)
        
        let loop = PlaybackLoop(10)
        
        for _ in 1...100000 {
            
            let seekPos = Double.random(in: 0..<loop.startTime)
            doTestSeekPosition(true, true, loop, seekPos, loop.startTime)
        }
    }
    
    // MARK: playTrack() tests ---------------------------------------------------------------------------------------------------------
    
    func testPlayTrack() {
        
        let session = PlaybackSession.start(track)
        scheduler.playTrack(session, 0)
        
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 0)
        XCTAssertNil(mockPlayerNode.scheduleSegment_endTime)
    }
    
    // MARK: seekToTime() tests ---------------------------------------------------------------------------------------------------------
    
    func testSeekToTime_noLoop_playing() {
        doSeekToTime(30, true)
    }
    
    func testSeekToTime_noLoop_paused() {
        doSeekToTime(30, false)
    }
    
    func testSeekToTime_withIncompleteLoop_playing() {
        doSeekToTime(30, true, PlaybackLoop(25))
    }
    
    func testSeekToTime_withIncompleteLoop_paused() {
        doSeekToTime(30, false, PlaybackLoop(25))
    }
    
    func testSeekToTime_withCompleteLoop_playing() {
        doSeekToTime(30, true, PlaybackLoop(25, 50))
    }
    
    func testSeekToTime_withCompleteLoop_paused() {
        doSeekToTime(30, false, PlaybackLoop(25, 50))
    }
    
    private func doSeekToTime(_ seekTime: Double, _ playing: Bool, _ loop: PlaybackLoop? = nil) {
        
        let session = PlaybackSession.start(track)
        
        if let theLoop = loop {
            
            PlaybackSession.beginLoop(theLoop.startTime)
            if let loopEndTime = theLoop.endTime {PlaybackSession.endLoop(loopEndTime)}
        }
        
        scheduler.seekToTime(session, seekTime, playing)
        
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)
        XCTAssertEqual(mockPlayerNode.played, playing)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, seekTime)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, loop?.endTime)
    }
    
    // MARK: pause(), resume(), and stop() tests ---------------------------------------------------------------------------------------------------------
    
    func testPauseAndResume() {
        
        var session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.pause()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertEqual(mockPlayerNode.paused, true)
        
        scheduler.resume()
        XCTAssertTrue(mockPlayerNode.isPlaying)
        
        session = PlaybackSession.startNewSessionForPlayingTrack()!
        scheduler.seekToTime(session, 30, true)
        XCTAssertTrue(mockPlayerNode.isPlaying)
        
        scheduler.pause()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        
        scheduler.resume()
        XCTAssertTrue(mockPlayerNode.isPlaying)
    }
    
    func testResume_trackNotCompleted() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.pause()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertTrue(mockPlayerNode.paused)
        
        // Track should not complete playback when resumed.
        scheduler.resume()
        
        XCTAssertFalse(self.trackCompletionMsgReceived || self.completedSessionIsCurrent)
    }
    
    func testResume_trackCompletedWhilePaused() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.pause()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertTrue(mockPlayerNode.paused)
        
        scheduler.segmentCompleted(session)
        
        // Track should complete playback when resumed.
        scheduler.resume()
        
        XCTAssertTrue(self.trackCompletionMsgReceived && self.completedSessionIsCurrent)
    }
    
    func testStop_playing() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.stop()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertEqual(mockPlayerNode.stopped, true)
    }
    
    func testStop_paused() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.pause()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertTrue(mockPlayerNode.paused)
        
        scheduler.stop()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertEqual(mockPlayerNode.stopped, true)
    }
    
    func testStop_completedWhilePaused() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.pause()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertTrue(mockPlayerNode.paused)
        
        scheduler.segmentCompleted(session)
        
        scheduler.stop()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertEqual(mockPlayerNode.stopped, true)
        
        XCTAssertFalse(self.trackCompletionMsgReceived || self.completedSessionIsCurrent)
    }
    
    // MARK: playLoop() tests ---------------------------------------------------------------------------------------------------------
    
    func testPlayLoop_incompleteLoop_noStartTime_playing() {
        _ = doPlayLoop(nil, nil, nil, true, 0, nil, nil)
    }
    
    func testPlayLoop_incompleteLoop_noStartTime_paused() {
        _ = doPlayLoop(nil, nil, nil, false, 0, nil, nil)
    }
    
    func testPlayLoop_incompleteLoop_startTimeOnly_playing() {
        _ = doPlayLoop(10, nil, nil, true, 0, nil, nil)
    }
    
    func testPlayLoop_incompleteLoop_startTimeOnly_paused() {
        _ = doPlayLoop(10, nil, nil, false, 0, nil, nil)
    }

    func testPlayLoop_noStartPosition_playing() {
        _ = doPlayLoop(10, 25, nil, true, 1, 10, 25)
    }

    func testPlayLoop_noStartPosition_paused() {
        _ = doPlayLoop(10, 25, nil, false, 1, 10, 25)
    }

    func testPlayLoop_startPositionOutsideLoop_playing() {
        
        for _ in 1...50000 {
            
            mockPlayerNode.resetMock()
            let startPos = Double.random(in: 25.001...track.duration)
            _ = doPlayLoop(10, 25, startPos, true, 0, nil, nil)
        }
        
        for _ in 1...50000 {
            
            mockPlayerNode.resetMock()
            let startPos = Double.random(in: 0..<10)
            _ = doPlayLoop(10, 25, startPos, true, 0, nil, nil)
        }
    }
    
    func testPlayLoop_startPositionOutsideLoop_paused() {
        
        for _ in 1...50000 {
            
            mockPlayerNode.resetMock()
            let startPos = Double.random(in: 25.001...track.duration)
            _ = doPlayLoop(10, 25, startPos, false, 0, nil, nil)
        }
        
        for _ in 1...50000 {
            
            mockPlayerNode.resetMock()
            let startPos = Double.random(in: 0..<10)
            _ = doPlayLoop(10, 25, startPos, false, 0, nil, nil)
        }
    }

    func testPlayLoop_withStartPosition_playing() {
        
        for _ in 1...100000 {
            
            mockPlayerNode.resetMock()
            let startPos = Double.random(in: 10...25)
            _ = doPlayLoop(10, 25, startPos, true, 1, startPos, 25)
        }
    }

    func testPlayLoop_withStartPosition_paused() {
        
        for _ in 1...100000 {
            
            mockPlayerNode.resetMock()
            let startPos = Double.random(in: 10...25)
            _ = doPlayLoop(10, 25, startPos, false, 1, startPos, 25)
        }
    }
    
    private func doPlayLoop(_ loopStartTime: Double? = nil, _ loopEndTime: Double? = nil, _ seekTime: Double? = nil, _ playing: Bool = true, _ expectedScheduleSegmentCallCount: Int, _ expectedScheduleSegmentStartTime: Double?, _ expectedScheduleSegmentEndTime: Double?) -> PlaybackSession {
        
        let session = PlaybackSession.start(track)

        if let startTime = loopStartTime {
            PlaybackSession.beginLoop(startTime)
        }
        
        if let endTime = loopEndTime {
            PlaybackSession.endLoop(endTime)
        }

        if let playbackStartTime = seekTime {
            scheduler.playLoop(session, playbackStartTime, playing)
        } else {
            scheduler.playLoop(session, playing)
        }
        
        if playing {
            mockPlayerNode.play()
        }
        
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)
        XCTAssertEqual(mockPlayerNode.played, playing)
                
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, expectedScheduleSegmentCallCount)
        
        if let loop = PlaybackSession.currentLoop, loop.isComplete, loop.containsPosition(seekTime ?? loop.startTime) {
            XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        } else {
            XCTAssertNil(mockPlayerNode.scheduleSegment_session)
        }
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, expectedScheduleSegmentStartTime)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, expectedScheduleSegmentEndTime)
                
        return session
    }
    
    // MARK: endLoop() tests ---------------------------------------------------------------------------------------------------------
    
    func testEndLoop_playing() {
        doEndLoop(true)
    }
    
    func testEndLoop_paused() {
        doEndLoop(false)
    }
    
    private func doEndLoop(_ playing: Bool) {
        
        var session = doPlayLoop(10, 25, nil, playing, 1, 10, 25)
        
        session = PlaybackSession.startNewSessionForPlayingTrack()!
        scheduler.endLoop(session, 25)
        
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)
        XCTAssertEqual(mockPlayerNode.played, playing)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 2)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 25)
        XCTAssertNil(mockPlayerNode.scheduleSegment_endTime)
    }
    
    // MARK: segmentCompleted() tests ---------------------------------------------------------------------------------------------------------
    
    func testSegmentCompleted_playing() {
        doSegmentCompleted(true, true)
    }
    
    func testSegmentCompleted_paused() {
        doSegmentCompleted(true, false)
    }
    
    func testSegmentCompleted_oldSession_playing() {
        doSegmentCompleted(false, true)
    }
    
    func testSegmentCompleted_oldSession_paused() {
        doSegmentCompleted(false, false)
    }
    
    private func doSegmentCompleted(_ isSessionCurrent: Bool, _ playing: Bool) {
        
        // Start a session, and put the player node in a playing state.
        let session = PlaybackSession.start(track)
        playing ? mockPlayerNode.play() : mockPlayerNode.pause()
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)

        if !isSessionCurrent {
            
            // Create a new session, thus invalidating the first one.
            _ = PlaybackSession.startNewSessionForPlayingTrack()
        }

        // Track completion should not be triggered, as the session that completed is not current.
        scheduler.segmentCompleted(session)
        
        // Even if no scheduling was done, the player's playback state should not have been altered (i.e. if it was playing, it is still playing).
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)

        XCTAssertEqual(self.trackCompletionMsgReceived, isSessionCurrent && playing)
        XCTAssertEqual(self.completedSessionIsCurrent, isSessionCurrent && playing)
    }
    
    // MARK: loopSegmentCompleted() tests ---------------------------------------------------------------------------------------------------------
    
    func testLoopSegmentCompleted_playing() {
        doLoopSegmentCompleted(true, true)
    }
    
    func testLoopSegmentCompleted_paused() {
        doLoopSegmentCompleted(true, false)
    }
    
    func testLoopSegmentCompleted_oldSession_playing() {
        doLoopSegmentCompleted(false, true)
    }
    
    func testLoopSegmentCompleted_oldSession_paused() {
        doLoopSegmentCompleted(false, false)
    }
    
    private func doLoopSegmentCompleted(_ isSessionCurrent: Bool, _ playing: Bool) {
        
        // Start a session, define a loop, and put the player node in a playing state, then invoke loopSegmentCompleted() with that same session.
        // This should result in a new loop segment being scheduled.
        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)
        playing ? mockPlayerNode.play() : mockPlayerNode.pause()
        
        if !isSessionCurrent {
            
            // Create a new session, thus invalidating the first one.
            _ = PlaybackSession.startNewSessionForPlayingTrack()
        }
        
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)
        
        doLoopSegmentIteration(session, isSessionCurrent, playing, isSessionCurrent ? 1 : 0)
    }
    
    private func doLoopSegmentIteration(_ session: PlaybackSession, _ isSessionCurrent: Bool, _ playing: Bool, _ expectedScheduleSegmentCallCount: Int) {
        
        scheduler.loopSegmentCompleted(session)
        
        // Check that playback state was not altered.
        XCTAssertEqual(mockPlayerNode.isPlaying, playing)
        
        // Scheduling should only take place if a current session has completed.
        
        // Iteration index (i.e. how many times the loop segment has already repeated) will determine the call count of scheduleSegment().
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, expectedScheduleSegmentCallCount)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, isSessionCurrent ? session : nil)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, isSessionCurrent ? session.loop?.startTime : nil)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, isSessionCurrent ? session.loop?.endTime : nil)
    }
    
    // MARK: Realistic scenario tests ---------------------------------------------------------------------------------------------------------
    
    func testLooping_multipleIterations() {
        
        let numberOfLoopIterations: Int = 5
        
        // Start a session, define a loop, and put the player node in a playing state, then invoke loopSegmentCompleted() with that same session.
        // This should result in a new loop segment being scheduled.
        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)
        
        scheduler.playLoop(session, true)
        
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        for index in 0..<numberOfLoopIterations {
            
            // Expect (index + 2) calls to scheduleSegment() because playLoop will result in 1 call, plus 1 for each loop iteration.
            doLoopSegmentIteration(session, true, true, index + 2)
        }
    }
}
