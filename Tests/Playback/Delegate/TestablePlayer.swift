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
    
    override func forceSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {
        
        forceSeekToTimeCallCount.increment()
        forceSeekToTime_track = track
        forceSeekToTime_time = time
        
        return super.forceSeekToTime(track, time)
    }
    
    func reset() {
        
        attemptSeekToTimeCallCount = 0
        attemptSeekToTime_track = nil
        attemptSeekToTime_time = 0
        attemptSeekResult = nil
    }
}
