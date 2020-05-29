import Foundation

class TestablePlayer: Player {
    
    var attemptSeekToTimeCallCount: Int = 0
    var attemptSeekToTime_track: Track?
    var attemptSeekToTime_time: Double?
    
    var attemptSeekResult: PlayerSeekResult?
    
    override func attemptSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {
        
        attemptSeekToTimeCallCount.increment()
        attemptSeekToTime_track = track
        attemptSeekToTime_time = time
        
        attemptSeekResult = super.attemptSeekToTime(track, time)
        return attemptSeekResult!
    }
    
    var forceSeekToTimeCallCount: Int = 0
    var forceSeekToTime_track: Track?
    var forceSeekToTime_time: Double?
    
    var forceSeekResult: PlayerSeekResult?
    
    override func forceSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {
        
        forceSeekToTimeCallCount.increment()
        forceSeekToTime_track = track
        forceSeekToTime_time = time
        
        forceSeekResult = super.forceSeekToTime(track, time)
        return forceSeekResult!
    }
    
    var toggleLoopCallCount: Int = 0
    var toggleLoopResult: PlaybackLoop?
    
    override func toggleLoop() -> PlaybackLoop? {
        
        toggleLoopCallCount.increment()
        toggleLoopResult = super.toggleLoop()
        return toggleLoopResult
    }
    
    var defineLoopCallCount: Int = 0
    var defineLoop_startTime: Double?
    var defineLoop_endTime: Double?
    
    override func defineLoop(_ loopStartPosition: Double, _ loopEndPosition: Double) {
        
        defineLoopCallCount.increment()
        defineLoop_startTime = loopStartPosition
        defineLoop_endTime = loopEndPosition
        
        super.defineLoop(loopStartPosition, loopEndPosition)
    }
    
    func reset() {
        
        attemptSeekToTimeCallCount = 0
        attemptSeekToTime_track = nil
        attemptSeekToTime_time = nil
        attemptSeekResult = nil
        
        forceSeekToTimeCallCount = 0
        forceSeekToTime_track = nil
        forceSeekToTime_time = nil
        forceSeekResult = nil
        
        toggleLoopCallCount = 0
        toggleLoopResult = nil
        
        defineLoopCallCount = 0
        defineLoop_startTime = nil
        defineLoop_endTime = nil
    }
}
