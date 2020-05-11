import AVFoundation
@testable import Aural

class MockScheduler: PlaybackSchedulerProtocol {
    
    var playerNode: MockPlayerNode
    
    init(_ playerNode: MockPlayerNode) {
        self.playerNode = playerNode
    }
    
    var seekPosition: Double = 0
    
    // --------------------------------
    
    var playTrack_session: PlaybackSession?
    var playTrack_startPosition: Double?
    
    func playTrack(_ playbackSession: PlaybackSession, _ startPosition: Double) {
        
        playerNode.stop()
        
        playTrack_session = playbackSession
        playTrack_startPosition = startPosition
        
        playerNode.play()
    }
    
    // --------------------------------
    
    var playLoop_session: PlaybackSession?
    var playLoop_startTime: Double?
    var playLoop_beginPlayback: Bool?
    
    func playLoop(_ playbackSession: PlaybackSession, _ beginPlayback: Bool) {
        
        playerNode.stop()
        
        playLoop_session = playbackSession
        playLoop_beginPlayback = beginPlayback
        
        if beginPlayback {
            playerNode.play()
        }
    }
    
    func playLoop(_ playbackSession: PlaybackSession, _ playbackStartTime: Double, _ beginPlayback: Bool) {
        
        playerNode.stop()
        
        playLoop_session = playbackSession
        playLoop_startTime = playbackStartTime
        playLoop_beginPlayback = beginPlayback
        
        if beginPlayback {
            playerNode.play()
        }
    }
    
    func endLoop(_ playbackSession: PlaybackSession, _ loopEndTime: Double) {
    }
    
    // --------------------------------
    
    var seekToTime_session: PlaybackSession?
    var seekToTime_time: Double?
    var seekToTime_beginPlayback: Bool?
    
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double, _ beginPlayback: Bool) {
        
        playerNode.stop()
        
        seekToTime_session = playbackSession
        seekToTime_time = seconds
        seekToTime_beginPlayback = beginPlayback
        
        if beginPlayback {
            playerNode.play()
        }
    }
    
    var paused: Bool = false
    var resumed: Bool = false
    var stopped: Bool = false
    
    func pause() {
        
        playerNode.pause()
        paused = true
    }
    
    func resume() {
        
        playerNode.play()
        resumed = true
    }
    
    func stop() {
        
        playerNode.stop()
        stopped = true
    }
    
    // -----------------------------------
    
    func reset() {
        
        seekPosition = 0
        
        playTrack_session = nil
        playTrack_startPosition = nil
        
        playLoop_session = nil
        playLoop_startTime = nil
        playLoop_beginPlayback = nil
        
        seekToTime_session = nil
        seekToTime_time = nil
        seekToTime_beginPlayback = nil
        
        paused = false
        resumed = false
        stopped = false
        
        playerNode.resetMock()
    }
}
