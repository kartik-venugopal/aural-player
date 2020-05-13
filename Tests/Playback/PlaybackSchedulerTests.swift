import XCTest
import Cocoa

class PlaybackSchedulerTests: XCTestCase, AsyncMessageSubscriber {
    
    private var scheduler: PlaybackScheduler!
    private var mockPlayerNode: MockPlayerNode!
    
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path"))
    
    var subscriberId: String {return self.className + String(describing: self.hashValue)}
    var trackCompletionMsgReceived: Bool = false

    override func setUp() {
        
        // This will be done only once
        if scheduler == nil {
            
            mockPlayerNode = MockPlayerNode()
            scheduler = PlaybackScheduler(mockPlayerNode)
            
            AsyncMessenger.subscribe([.playbackCompleted], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
        }
        
        track.setDuration(300)
        
        mockPlayerNode.resetMock()
        
        trackCompletionMsgReceived = false
        
        _ = PlaybackSession.endCurrent()
        
        XCTAssertNil(PlaybackSession.currentSession)
        XCTAssertFalse(mockPlayerNode.played || mockPlayerNode.paused || mockPlayerNode.stopped || mockPlayerNode.isPlaying)
    }
    
    override func tearDown() {
        
        // Prevent test case objects from receiving each other's messages.
        AsyncMessenger.unsubscribe([.playbackCompleted], subscriber: self)
    }
    
    func testPlayTrack() {
        
        let session = PlaybackSession.start(track)
        scheduler.playTrack(session, 0)
        
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 0)
        XCTAssertNil(mockPlayerNode.scheduleSegment_endTime)
    }
    
    func testSeekToTime_noLoop_playing() {
        doSeekToTime(30, true)
    }
    
    func testSeekToTime_noLoop_paused() {
        doSeekToTime(30, false)
    }
    
    func testSeekToTime_withIncompleteLoop_playing() {
        doSeekToTime(30, true, PlaybackLoop(25))
    }
    
    func testSeekToTime_withIncomplete_paused() {
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
    
    func testResume_trackCompletedWhilePaused() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.pause()
        XCTAssertEqual(mockPlayerNode.paused, true)
        
        scheduler.segmentCompleted(session)
        
        // Track should complete playback when resumed.
        scheduler.resume()
        
        // Wait 1 second, then validate
        executeAfter(1) {
            XCTAssertTrue(self.trackCompletionMsgReceived)
        }
    }
    
    func testStop_playing() {
        
        let session = PlaybackSession.start(track)

        scheduler.playTrack(session, 0)
        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        scheduler.stop()
        XCTAssertFalse(mockPlayerNode.isPlaying)
        XCTAssertEqual(mockPlayerNode.stopped, true)
    }
    
    func testPlayLoop_incompleteLoop() {

        // Define an incomplete loop
        let session = PlaybackSession.start(track)
        PlaybackSession.beginLoop(10)

        scheduler.playLoop(session, true)

        // No scheduling should take place.
        XCTAssertFalse(mockPlayerNode.isPlaying || mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 0)
        XCTAssertNil(mockPlayerNode.scheduleSegment_session)
    }

    func testPlayLoop_noStartPosition_playing() {

        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        scheduler.playLoop(session, true)

        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, session.loop?.startTime)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, session.loop?.endTime)
    }

    func testPlayLoop_noStartPosition_paused() {

        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        scheduler.playLoop(session, false)

        XCTAssertFalse(mockPlayerNode.isPlaying || mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, session.loop?.startTime)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, session.loop?.endTime)
    }

    func testPlayLoop_startPositionOutsideLoop() {

        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        // Start time is invalid (i.e. outside the bounds of the defined loop).
        scheduler.playLoop(session, 47, true)

        // No scheduling should take place.
        XCTAssertFalse(mockPlayerNode.isPlaying || mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 0)
        XCTAssertNil(mockPlayerNode.scheduleSegment_session)
    }

    func testPlayLoop_withStartPosition_playing() {

        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        scheduler.playLoop(session, 15.78, true)

        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)

        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 15.78)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, session.loop?.endTime)
    }

    func testPlayLoop_withStartPosition_paused() {

        let session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        scheduler.playLoop(session, 15.78, false)

        XCTAssertFalse(mockPlayerNode.isPlaying || mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 15.78)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, session.loop?.endTime)
    }
    
    func testEndLoop_playing() {
        
        var session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        scheduler.playLoop(session, true)

        XCTAssertTrue(mockPlayerNode.isPlaying && mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 10)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, session.loop?.endTime)
        
        session = PlaybackSession.startNewSessionForPlayingTrack()!
        scheduler.endLoop(session, 25)
        
        XCTAssertTrue(mockPlayerNode.isPlaying)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 2)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 25)
        XCTAssertNil(mockPlayerNode.scheduleSegment_endTime)
    }
    
    func testEndLoop_paused() {
        
        var session = PlaybackSession.start(track)
        PlaybackSession.defineLoop(10, 25)

        scheduler.playLoop(session, false)

        XCTAssertFalse(mockPlayerNode.isPlaying || mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 1)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 10)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_endTime, session.loop?.endTime)
        
        session = PlaybackSession.startNewSessionForPlayingTrack()!
        scheduler.endLoop(session, 25)
        
        XCTAssertFalse(mockPlayerNode.isPlaying || mockPlayerNode.played)
        
        XCTAssertEqual(mockPlayerNode.scheduleSegment_callCount, 2)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_session, session)
        XCTAssertEqual(mockPlayerNode.scheduleSegment_startTime, 25)
        XCTAssertNil(mockPlayerNode.scheduleSegment_endTime)
    }
    
    func testSegmentCompleted() {
        // TODO
    }
    
    func testLoopSegmentCompleted() {
        // TODO
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        trackCompletionMsgReceived = message is PlaybackCompletedAsyncMessage
    }
}

/*
 func testSegmentCompleted_trackCompletion() {

     // Start a session, put the player node in a playing state, then invoke segmentCompleted() with that same session.
     // This should trigger a track completion notification.
     let session = PlaybackSession.start(track)
     mockPlayerNode.play()

     scheduler.segmentCompleted(session)

     // Wait 1 second, then validate
     executeAfter(1) {
         XCTAssertTrue(self.msgReceived)
     }
 }
 
 func testSegmentCompleted_oldSession() {

     // Start a session, and put the player node in a playing state.
     let session = PlaybackSession.start(track)
     mockPlayerNode.play()

     // Create a new session, thus invalidating the first one.
     _ = PlaybackSession.startNewSessionForPlayingTrack()

     scheduler.segmentCompleted(session)

     // Wait 1 second, then validate
     executeAfter(1) {
         XCTAssertFalse(self.msgReceived)
     }
 }
 */
