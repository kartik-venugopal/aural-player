import XCTest
@testable import Aural

/*
    Unit tests for Player
 */
class PlayerTests: XCTestCase {
    
    private var player: Player!
    
    private var mockPlayerGraph: MockPlayerGraph!
    private var mockScheduler: MockScheduler!
    private var mockPlayerNode: MockPlayerNode!
    
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path"))
    
    override func setUp() {
        
        if player == nil {
            
            mockPlayerGraph = MockPlayerGraph()
            mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
            mockScheduler = MockScheduler(mockPlayerNode)
            
            player = Player(mockPlayerGraph, mockScheduler)
        }
        
        reset()
    }
    
    private func reset() {
        
        mockScheduler.reset()
        player.stop()
        
        _ = PlaybackSession.endCurrent()
    }

    func testPlay_startTimeOnly() {
        
        let trackDuration: Double = 300
        
        for startPos: Double in [0, 0.76, 1, 3.29, 20, 35, 200, 299, 299.5, 299.999] {
            
            reset()
            doTestPlay(trackDuration: trackDuration, playStartPos: startPos)
        }
    }
    
    func testPlay_loop() {
        doTestPlay(trackDuration: 300, playStartPos: 20, playEndPos: 40)
    }
    
    private func doTestPlay(trackDuration: Double, playStartPos: Double, playEndPos: Double? = nil) {
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        
        track.setDuration(trackDuration)
        
        player.play(track, playStartPos, playEndPos)
        
        let curSession: PlaybackSession? = PlaybackSession.currentSession
        
        XCTAssertNotNil(curSession)
        
        if let session = curSession {
            
            XCTAssertEqual(session.track, track)
            
            XCTAssertEqual(session.hasLoop() && session.hasCompleteLoop(), playEndPos != nil)
            XCTAssertEqual(session.loop != nil, playEndPos != nil)
            
            if let loop = session.loop {
                
                XCTAssertEqual(loop.startTime, playStartPos)
                XCTAssertEqual(loop.endTime, playEndPos)
                
                XCTAssertNotNil(mockScheduler.playLoop_session)
                
                if let playLoop_session = mockScheduler.playLoop_session {
                    XCTAssertEqual(playLoop_session, session)
                }
                
                XCTAssertEqual(mockScheduler.playLoop_beginPlayback, true)
                
            } else {
                
                XCTAssertNotNil(mockScheduler.playTrack_session)
                if let playTrack_session = mockScheduler.playTrack_session {
                    XCTAssertEqual(playTrack_session, session)
                }
                
                XCTAssertNotNil(mockScheduler.playTrack_startPosition)
                if let playTrack_startPos = mockScheduler.playTrack_startPosition {
                    XCTAssertEqual(playTrack_startPos, playStartPos)
                }
            }
        }
        
        XCTAssertEqual(player.state, PlaybackState.playing)
    }
    
    func testAttemptSeekToTime_noLoop_timeLessThan0_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: -5.12, pausedBeforeSeek: false, expectedSeekPosition: 0, loopRemovalExpected: false, trackPlaybackCompletionExpected: false)
    }
    
    func testAttemptSeekToTime_noLoop_timeLessThan0_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: -5.12, pausedBeforeSeek: true, expectedSeekPosition: 0, loopRemovalExpected: false, trackPlaybackCompletionExpected: false)
    }
    
    func testAttemptSeekToTime_noLoop_validTime_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 27.89, pausedBeforeSeek: false, expectedSeekPosition: 27.89, loopRemovalExpected: false, trackPlaybackCompletionExpected: false)
    }
    
    func testAttemptSeekToTime_noLoop_validTime_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 27.89, pausedBeforeSeek: true, expectedSeekPosition: 27.89, loopRemovalExpected: false, trackPlaybackCompletionExpected: false)
    }
    
    func testAttemptSeekToTime_noLoop_timeGreaterThanDuration_playing() {

        // Track should complete playback
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 302.76, pausedBeforeSeek: false, expectedSeekPosition: 300, loopRemovalExpected: false, trackPlaybackCompletionExpected: true)
    }
    
    func testAttemptSeekToTime_noLoop_timeGreaterThanDuration_paused() {

        // Track should NOT complete playback
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 302.76, pausedBeforeSeek: true, expectedSeekPosition: 300, loopRemovalExpected: false, trackPlaybackCompletionExpected: false)
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeBefore0_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: -2.67, pausedBeforeSeek: false, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeBefore0_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: -2.67, pausedBeforeSeek: true, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeGreaterThanDuration_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 310.11, pausedBeforeSeek: false, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeGreaterThanDuration_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 310.11, pausedBeforeSeek: true, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeBeforeLoopStart_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 10.59, pausedBeforeSeek: false, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeBeforeLoopStart_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 10.59, pausedBeforeSeek: true, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeAfterLoopEnd_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 56.78, pausedBeforeSeek: false, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeAfterLoopEnd_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 56.78, pausedBeforeSeek: true, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeWithinLoop_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 32.43, pausedBeforeSeek: false, expectedSeekPosition: 32.43, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withCompleteLoop_timeWithinLoop_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 32.43, pausedBeforeSeek: true, expectedSeekPosition: 32.43, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20, 40))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeBefore0_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: -2.67, pausedBeforeSeek: false, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeBefore0_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: -2.67, pausedBeforeSeek: true, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeGreaterThanDuration_playing() {
        
        // Track playback should complete
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 310.11, pausedBeforeSeek: false, expectedSeekPosition: 300, loopRemovalExpected: false, trackPlaybackCompletionExpected: true, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeGreaterThanDuration_paused() {
        
        // Track playback should NOT complete
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 310.11, pausedBeforeSeek: true, expectedSeekPosition: 300, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeBeforeLoopStart_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 10.59, pausedBeforeSeek: false, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeBeforeLoopStart_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 10.59, pausedBeforeSeek: true, expectedSeekPosition: 20, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeAfterLoopStart_playing() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 56.78, pausedBeforeSeek: false, expectedSeekPosition: 56.78, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    func testAttemptSeekToTime_withIncompleteLoop_timeAfterLoopStart_paused() {
        
        doTestAttemptSeekToTime(trackDuration: 300, playStartPos: 0, attemptedSeekTime: 56.78, pausedBeforeSeek: true, expectedSeekPosition: 56.78, loopRemovalExpected: false, trackPlaybackCompletionExpected: false, playbackLoop: PlaybackLoop(20))
    }
    
    private func doTestAttemptSeekToTime(trackDuration: Double, playStartPos: Double, attemptedSeekTime: Double, pausedBeforeSeek: Bool, expectedSeekPosition: Double, loopRemovalExpected: Bool, trackPlaybackCompletionExpected: Bool, playbackLoop: PlaybackLoop? = nil) {
        
        track.setDuration(trackDuration)
        
        // Play and pause track
        player.play(track, playStartPos)
        
        if pausedBeforeSeek {
            player.pause()
        }
        
        // Define a loop if necessary
        if let loop = playbackLoop {
            
            PlaybackSession.beginLoop(loop.startTime)
            
            if let loopEndTime = loop.endTime {
                PlaybackSession.endLoop(loopEndTime)
            }
        }
        
        // Validate the resulting playback session
        let curSession: PlaybackSession? = PlaybackSession.currentSession
        
        XCTAssertNotNil(curSession)
        
        if let session = curSession {
            XCTAssertEqual(session.track, track)
        }
        
        // Seek
        let seekResult = player.attemptSeekToTime(track, attemptedSeekTime)
        
        // Validate the seek result
        XCTAssertEqual(seekResult.actualSeekPosition, expectedSeekPosition)
        XCTAssertEqual(seekResult.loopRemoved, loopRemovalExpected)
        XCTAssertEqual(seekResult.trackPlaybackCompleted, trackPlaybackCompletionExpected)
        
        // Validate the resulting playback state
        XCTAssertEqual(player.state, pausedBeforeSeek ? PlaybackState.paused : PlaybackState.playing)
    }
    
    func testPause() {
        
        track.setDuration(300)
        player.play(track, 0)
        
        XCTAssertEqual(player.state, PlaybackState.playing)
        
        player.pause()
        
        XCTAssertTrue(mockScheduler.paused)
        XCTAssertEqual(player.state, PlaybackState.paused)
    }
}
