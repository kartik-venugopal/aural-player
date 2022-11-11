//
//  PlaybackSessionTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

/*
    Unit tests for PlaybackSession
 */
class PlaybackSessionTests: XCTestCase {
    
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path/song.mp3"))
    
    override func setUp() {
        _ = PlaybackSession.endCurrent()
    }
    
    func testEqualsComparison() {
        
        let numberOfSessions: Int = 10000
        
        for _ in 1...numberOfSessions {
            
            // Compare the new session to itself (should return true)
            let session = PlaybackSession.start(self.track)
            XCTAssertEqual(session, session)
            
            _ = PlaybackSession.endCurrent()
        }
    }
    
    func testStart_sessionCreation() {
            
        let session = PlaybackSession.start(self.track)
        
        XCTAssertEqual(self.track, session.track)
        
        XCTAssertFalse(session.id.trim().isEmpty)
        XCTAssertGreaterThan(session.timestamp, 0)
        
        XCTAssertNil(session.loop)
        XCTAssertFalse(session.hasLoop())
        XCTAssertFalse(session.hasCompleteLoop())
    }
    
    func testStart_sessionIDUniqueness() {
        
        var sessionIDs: Set<String> = Set()
        let numberOfIDs: Int = 100000
        
        for _ in 1...numberOfIDs {
            
            let session = PlaybackSession.start(self.track)
            sessionIDs.insert(session.id)
            
            _ = PlaybackSession.endCurrent()
        }
        
        XCTAssert(sessionIDs.count == numberOfIDs)
    }
    
    func testStartNewSessionForPlayingTrack() {
        
        let numberOfSessions: Int = 1000
        
        for _ in 1...numberOfSessions {
            
            let oldSession = PlaybackSession.start(self.track)
            XCTAssertTrue(PlaybackSession.isCurrent(oldSession))
            
            let _newSession = PlaybackSession.startNewSessionForPlayingTrack()
            
            // Since there is a current session, newSession should not be nil
            XCTAssertNotNil(_newSession)
            
            if let newSession = _newSession {
                
                // Ensure the new session is now the current one
                XCTAssertTrue(PlaybackSession.isCurrent(newSession))
                XCTAssertFalse(PlaybackSession.isCurrent(oldSession))
            
                // Ensure session and newSession have different IDs
                XCTAssertNotEqual(oldSession.id, newSession.id)
                
                // Ensure session and newSession have the same track
                XCTAssertEqual(oldSession.track, newSession.track)
                
                // Ensure session and newSession have the same timestamp
                XCTAssertEqual(oldSession.timestamp, newSession.timestamp)
                
                // Ensure session and newSession have the same loop
                XCTAssertEqual(oldSession.loop, newSession.loop)
            }
            
            _ = PlaybackSession.endCurrent()
        }
    }
    
    func testStartNewSessionForPlayingTrack_noPlayingTrack() {
        
        _ = PlaybackSession.endCurrent()
        
        let newSession = PlaybackSession.startNewSessionForPlayingTrack()
        XCTAssertNil(newSession)
    }
    
    func testEndCurrent() {
        
        let session = PlaybackSession.start(self.track)
        XCTAssertEqual(PlaybackSession.currentSession, session)
        
        let endedSession = PlaybackSession.endCurrent()
        XCTAssertEqual(endedSession, session)
        
        XCTAssertFalse(PlaybackSession.hasCurrentSession())
        XCTAssertNil(PlaybackSession.currentSession)
        
        XCTAssertNil(PlaybackSession.currentLoop)
        XCTAssertFalse(PlaybackSession.hasLoop())
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
    }
    
    func testEndCurrent_noCurrentSession() {
        
        _ = PlaybackSession.endCurrent()
        
        let endedSession = PlaybackSession.endCurrent()
        XCTAssertNil(endedSession)
        XCTAssertFalse(PlaybackSession.hasCurrentSession())
    }
    
    func testCurrentSession() {
        
        let oldSession = PlaybackSession.start(self.track)
        XCTAssertEqual(PlaybackSession.currentSession, oldSession)
        
        let newSession = PlaybackSession.startNewSessionForPlayingTrack()
        XCTAssertEqual(PlaybackSession.currentSession, newSession)
        
        _ = PlaybackSession.endCurrent()
        XCTAssertNil(PlaybackSession.currentSession)
    }
    
    func testIsCurrent() {
        
        let oldSession = PlaybackSession.start(self.track)
        XCTAssertTrue(PlaybackSession.isCurrent(oldSession))
        
        let newSession = PlaybackSession.startNewSessionForPlayingTrack()
        XCTAssertFalse(PlaybackSession.isCurrent(oldSession))
        XCTAssertNotNil(newSession)
        
        if let theNewSession = newSession {
            
            XCTAssertTrue(PlaybackSession.isCurrent(theNewSession))
            
            _ = PlaybackSession.endCurrent()
            XCTAssertFalse(PlaybackSession.isCurrent(theNewSession))
        }
    }
    
    func testHasCurrentSession() {
        
        _ = PlaybackSession.start(self.track)
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        _ = PlaybackSession.startNewSessionForPlayingTrack()
        XCTAssertTrue(PlaybackSession.hasCurrentSession())
        
        _ = PlaybackSession.endCurrent()
        XCTAssertFalse(PlaybackSession.hasCurrentSession())
    }
    
    func testBeginLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        let startTime: Double = 25
        PlaybackSession.beginLoop(startTime)
        
        // Check session loop
        
        XCTAssertTrue(session.hasLoop())
        XCTAssertFalse(session.hasCompleteLoop())
        XCTAssertNotNil(session.loop)
        
        if let loop = session.loop {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertNil(loop.endTime)
        }
        
        // Check PlaybackSession loop
        
        XCTAssertTrue(PlaybackSession.hasLoop())
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        XCTAssertNotNil(PlaybackSession.currentLoop)
        
        if let loop = PlaybackSession.currentLoop {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertNil(loop.endTime)
        }
    }
    
    func testEndLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        // Begin loop ------------------------------
        
        let startTime: Double = 25
        PlaybackSession.beginLoop(startTime)
        
        // Check session loop
        
        XCTAssertTrue(session.hasLoop())
        XCTAssertFalse(session.hasCompleteLoop())
        XCTAssertNotNil(session.loop)
        
        if let loop = session.loop {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertNil(loop.endTime)
        }
        
        // Check PlaybackSession loop
        
        XCTAssertTrue(PlaybackSession.hasLoop())
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        XCTAssertNotNil(PlaybackSession.currentLoop)
        
        if let loop = PlaybackSession.currentLoop {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertNil(loop.endTime)
        }
        
        // End loop ------------------------------
        
        let endTime: Double = 37
        PlaybackSession.endLoop(endTime)
        
        // Check session loop
        
        XCTAssertTrue(session.hasLoop())
        XCTAssertTrue(session.hasCompleteLoop())
        XCTAssertNotNil(session.loop)
        XCTAssertNotNil(session.loop?.endTime)
        
        if let loop = session.loop, let loopEndTime = loop.endTime {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertEqual(loopEndTime, endTime)
        }
        
        // Check PlaybackSession loop
        
        XCTAssertTrue(PlaybackSession.hasLoop())
        XCTAssertTrue(PlaybackSession.hasCompleteLoop())
        XCTAssertNotNil(PlaybackSession.currentLoop)
        XCTAssertNotNil(PlaybackSession.currentLoop?.endTime)
        
        if let loop = PlaybackSession.currentLoop, let loopEndTime = loop.endTime {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertEqual(loopEndTime, endTime)
        }
    }
    
    func testDefineLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        XCTAssertNil(session.loop)
        XCTAssertFalse(session.hasLoop())
        XCTAssertFalse(session.hasCompleteLoop())
        
        XCTAssertNil(PlaybackSession.currentLoop)
        XCTAssertFalse(PlaybackSession.hasLoop())
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        
        let startTime: Double = 25
        let endTime: Double = 37
        
        PlaybackSession.defineLoop(startTime, endTime)
        
        // Check session loop
        
        XCTAssertTrue(session.hasLoop())
        XCTAssertTrue(session.hasCompleteLoop())
        XCTAssertNotNil(session.loop)
        XCTAssertNotNil(session.loop?.endTime)
        
        if let loop = session.loop, let loopEndTime = loop.endTime {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertEqual(loopEndTime, endTime)
        }
        
        // Check PlaybackSession loop
        
        XCTAssertTrue(PlaybackSession.hasLoop())
        XCTAssertTrue(PlaybackSession.hasCompleteLoop())
        XCTAssertNotNil(PlaybackSession.currentLoop)
        XCTAssertNotNil(PlaybackSession.currentLoop?.endTime)
        
        if let loop = PlaybackSession.currentLoop, let loopEndTime = loop.endTime {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertEqual(loopEndTime, endTime)
        }
    }
    
    func testRemoveLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        XCTAssertNil(session.loop)
        XCTAssertFalse(session.hasLoop())
        XCTAssertFalse(session.hasCompleteLoop())
        
        XCTAssertNil(PlaybackSession.currentLoop)
        XCTAssertFalse(PlaybackSession.hasLoop())
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        
        // Define loop -------------------------------------
        
        let startTime: Double = 25
        let endTime: Double = 37
        
        PlaybackSession.defineLoop(startTime, endTime)
        
        // Check session loop
        
        XCTAssertTrue(session.hasLoop())
        XCTAssertTrue(session.hasCompleteLoop())
        XCTAssertNotNil(session.loop)
        XCTAssertNotNil(session.loop?.endTime)
        
        if let loop = session.loop, let loopEndTime = loop.endTime {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertEqual(loopEndTime, endTime)
        }
        
        // Check PlaybackSession loop
        
        XCTAssertTrue(PlaybackSession.hasLoop())
        XCTAssertTrue(PlaybackSession.hasCompleteLoop())
        XCTAssertNotNil(PlaybackSession.currentLoop)
        XCTAssertNotNil(PlaybackSession.currentLoop?.endTime)
        
        if let loop = PlaybackSession.currentLoop, let loopEndTime = loop.endTime {
            
            XCTAssertEqual(loop.startTime, startTime)
            XCTAssertEqual(loopEndTime, endTime)
        }
        
        // Remove loop -------------------------------------
        
        PlaybackSession.removeLoop()
        
        XCTAssertNil(session.loop)
        XCTAssertFalse(session.hasLoop())
        XCTAssertFalse(session.hasCompleteLoop())
        
        XCTAssertNil(PlaybackSession.currentLoop)
        XCTAssertFalse(PlaybackSession.hasLoop())
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
    }
    
    func testHasLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        // Check session loop
        XCTAssertFalse(session.hasLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasLoop())
        
        // Begin loop ------------------------------
        
        let startTime: Double = 25
        PlaybackSession.beginLoop(startTime)
        
        // Check session loop
        XCTAssertTrue(session.hasLoop())
        
        // Check PlaybackSession loop
        XCTAssertTrue(PlaybackSession.hasLoop())
        
        // End loop ------------------------------
        
        let endTime: Double = 37
        PlaybackSession.endLoop(endTime)
        
        // Check session loop
        XCTAssertTrue(session.hasLoop())
        
        // Check PlaybackSession loop
        XCTAssertTrue(PlaybackSession.hasLoop())
        
        // Remove loop -----------------------------
        
        PlaybackSession.removeLoop()
        
        // Check session loop
        XCTAssertFalse(session.hasLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasLoop())
        
        // End session ------------------------------
        
        _ = PlaybackSession.endCurrent()
        
        // Check session loop
        XCTAssertFalse(session.hasLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasLoop())
    }
    
    func testHasCompleteLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        // Check session loop
        XCTAssertFalse(session.hasCompleteLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        
        // Begin loop ------------------------------
        
        let startTime: Double = 25
        PlaybackSession.beginLoop(startTime)
        
        // Check session loop
        XCTAssertFalse(session.hasCompleteLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        
        // End loop ------------------------------
        
        let endTime: Double = 37
        PlaybackSession.endLoop(endTime)
        
        // Check session loop
        XCTAssertTrue(session.hasCompleteLoop())
        
        // Check PlaybackSession loop
        XCTAssertTrue(PlaybackSession.hasCompleteLoop())
        
        // Remove loop -----------------------------
        
        PlaybackSession.removeLoop()
        
        // Check session loop
        XCTAssertFalse(session.hasCompleteLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
        
        // End session ------------------------------
        
        _ = PlaybackSession.endCurrent()
        
        // Check session loop
        XCTAssertFalse(session.hasCompleteLoop())
        
        // Check PlaybackSession loop
        XCTAssertFalse(PlaybackSession.hasCompleteLoop())
    }
    
    func testCurrentLoop() {
        
        let session = PlaybackSession.start(self.track)
        
        XCTAssertNil(session.loop)
        XCTAssertNil(PlaybackSession.currentLoop)
        
        // Begin loop ------------------------------
        
        let startTime: Double = 25
        PlaybackSession.beginLoop(startTime)
        
        XCTAssertNotNil(session.loop)
        XCTAssertNotNil(PlaybackSession.currentLoop)
        XCTAssertEqual(session.loop, PlaybackSession.currentLoop)
        
        // End loop ------------------------------
        
        let endTime: Double = 37
        PlaybackSession.endLoop(endTime)
        
        XCTAssertNotNil(session.loop)
        XCTAssertNotNil(PlaybackSession.currentLoop)
        XCTAssertEqual(session.loop, PlaybackSession.currentLoop)
        
        // Remove loop -----------------------------
        
        PlaybackSession.removeLoop()
        
        XCTAssertNil(session.loop)
        XCTAssertNil(PlaybackSession.currentLoop)
        
        // End session ------------------------------
        
        _ = PlaybackSession.endCurrent()
        
        XCTAssertNil(session.loop)
        XCTAssertNil(PlaybackSession.currentLoop)
    }
}
