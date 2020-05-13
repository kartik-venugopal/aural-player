import XCTest

/*
    Unit tests for PlaybackLoop
 */
class PlaybackLoopTests: XCTestCase {

    func testLoopCreation_startTimeOnly() {
        
        let startTime: Double = 15.98732478324
        let loop = PlaybackLoop(startTime)
        
        XCTAssertEqual(loop.startTime, startTime, accuracy: 0.001)
        XCTAssertNil(loop.endTime)
    }
    
    func testLoopCreation_completeLoop() {
        
        let startTime: Double = 15.98732478324
        let endTime: Double = 37.3294823489
        
        let loop = PlaybackLoop(startTime, endTime)
        
        XCTAssertEqual(loop.startTime, startTime, accuracy: 0.001)
        
        XCTAssertNotNil(loop.endTime)
        if let loopEndTime = loop.endTime {
            XCTAssertEqual(loopEndTime, endTime, accuracy: 0.001)
        }
    }
    
    func testIsComplete_incompleteLoop() {
        
        XCTAssertFalse(PlaybackLoop(10).isComplete)
        
        // Create a complete loop and then unset endTime to make it incomplete.
        var loop = PlaybackLoop(10, 20)
        loop.endTime = nil
        
        XCTAssertFalse(loop.isComplete)
    }
    
    func testIsComplete_completeLoop() {
        
        XCTAssertTrue(PlaybackLoop(10, 20).isComplete)
        
        // Create an incomplete loop, then complete it by defining endTime.
        var loop = PlaybackLoop(10)
        loop.endTime = 20
        
        XCTAssertTrue(loop.isComplete)
    }
    
    func testDuration_incompleteLoop() {
        
        XCTAssertEqual(PlaybackLoop(10).duration, 0)
        
        // Create a complete loop and then unset endTime to make it incomplete.
        var loop = PlaybackLoop(10, 20)
        loop.endTime = nil
        
        XCTAssertEqual(loop.duration, 0)
    }
    
    func testDuration_completeLoop() {
        
        XCTAssertEqual(PlaybackLoop(10, 20).duration, 10, accuracy: 0.001)
        
        // Create an  incomplete loop and then complete it by defining endTime.
        var loop = PlaybackLoop(10)
        loop.endTime = 20
        
        XCTAssertEqual(loop.duration, 10, accuracy: 0.001)
    }
    
    func testContainsPosition_incompleteLoop() {
        
        let loop = PlaybackLoop(10)
        
        XCTAssertFalse(loop.containsPosition(5))
        XCTAssertTrue(loop.containsPosition(10))
        XCTAssertTrue(loop.containsPosition(15))
    }
    
    func testContainsPosition_completeLoop() {
        
        let loop = PlaybackLoop(10, 20)
        
        XCTAssertFalse(loop.containsPosition(5))
        
        XCTAssertTrue(loop.containsPosition(10))
        XCTAssertTrue(loop.containsPosition(15))
        XCTAssertTrue(loop.containsPosition(20))
        
        XCTAssertFalse(loop.containsPosition(25))
    }
    
    func testEquality() {
        
        var loop1: PlaybackLoop? = nil
        var loop2: PlaybackLoop? = nil
        XCTAssertEqual(loop1, loop2)
        
        loop1 = PlaybackLoop(10)
        loop2 = nil
        XCTAssertNotEqual(loop1, loop2)
        
        loop1 = PlaybackLoop(10, 20)
        loop2 = nil
        XCTAssertNotEqual(loop1, loop2)
        
        loop1 = PlaybackLoop(10)
        loop2 = PlaybackLoop(10)
        XCTAssertEqual(loop1, loop2)
        
        loop1 = PlaybackLoop(10)
        loop2 = PlaybackLoop(10, 20)
        XCTAssertNotEqual(loop1, loop2)
        
        loop1 = PlaybackLoop(10, 20)
        loop2 = PlaybackLoop(10, 20)
        XCTAssertEqual(loop1, loop2)
    }
}
