import XCTest
@testable import Aural

/*
    Unit tests for Player
 */
class PlayerTests: XCTestCase {
    
    private var player: Player!
    
    private var mockPlayerGraph: MockPlayerGraph!
    private var mockScheduler: MockScheduler!
    
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path"))
    
    override func setUp() {
        
        if player == nil {
            
            mockPlayerGraph = MockPlayerGraph()
            mockScheduler = MockScheduler()
            
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
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        
        track.setDuration(300)
        
        for startPos: Double in [0, 0.76, 1, 3.29, 20, 35, 200, 299, 299.5, 299.999] {
            
            reset()
        
            player.play(track, startPos)
            
            let curSession: PlaybackSession? = PlaybackSession.currentSession
            
            XCTAssertNotNil(curSession)
            
            if let session = curSession {
                
                XCTAssertEqual(session.track, track)
                XCTAssertFalse(session.hasLoop())
                
                XCTAssertNotNil(mockScheduler.playTrack_session)
                if let playTrack_session = mockScheduler.playTrack_session {
                    XCTAssertEqual(playTrack_session, session)
                }
            }
            
            XCTAssertNotNil(mockScheduler.playTrack_startPosition)
            if let playTrack_startPos = mockScheduler.playTrack_startPosition {
                XCTAssertEqual(playTrack_startPos, startPos)
            }
            
            XCTAssertEqual(player.state, PlaybackState.playing)
        }
    }
    
    func testPlay_loop() {
        
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        
        let startPos: Double = 0
        player.play(track, startPos)
        
        let curSession: PlaybackSession? = PlaybackSession.currentSession
        
        XCTAssertNotNil(curSession)
        
        if let session = curSession {
            
            XCTAssertEqual(session.track, track)
            XCTAssertFalse(session.hasLoop())
            
            XCTAssertNotNil(mockScheduler.playTrack_session)
            if let playTrack_session = mockScheduler.playTrack_session {
                XCTAssertEqual(playTrack_session, session)
            }
        }
        
        XCTAssertNotNil(mockScheduler.playTrack_startPosition)
        if let playTrack_startPos = mockScheduler.playTrack_startPosition {
            XCTAssertEqual(playTrack_startPos, startPos)
        }
        
        XCTAssertEqual(player.state, PlaybackState.playing)
    }
}
