import Foundation
@testable import Aural

class MockScheduler: PlaybackSchedulerProtocol {
    
    var seekPosition: Double = 0
    
    // --------------------------------
    
    var playTrack_session: PlaybackSession?
    var playTrack_startPosition: Double?
    
    func playTrack(_ playbackSession: PlaybackSession, _ startPosition: Double) {
        
        playTrack_session = playbackSession
        playTrack_startPosition = startPosition
    }
    
    // --------------------------------
    
    var playLoop_session: PlaybackSession?
    var playLoop_startTime: Double?
    var playLoop_beginPlayback: Bool?
    
    func playLoop(_ playbackSession: PlaybackSession, _ beginPlayback: Bool) {
        
        playLoop_session = playbackSession
        playLoop_beginPlayback = beginPlayback
    }
    
    func playLoop(_ playbackSession: PlaybackSession, _ playbackStartTime: Double, _ beginPlayback: Bool) {
        
        playLoop_session = playbackSession
        playLoop_startTime = playbackStartTime
        playLoop_beginPlayback = beginPlayback
    }
    
    func endLoop(_ playbackSession: PlaybackSession, _ loopEndTime: Double) {
    }
    
    // --------------------------------
    
    var seekToTime_session: PlaybackSession?
    var seekToTime_time: Double?
    var seekToTime_beginPlayback: Bool?
    
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double, _ beginPlayback: Bool) {
        
        seekToTime_session = playbackSession
        seekToTime_time = seconds
        seekToTime_beginPlayback = beginPlayback
    }
    
    func pause() {
    }
    
    func resume() {
    }
    
    func stop() {
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
    }
}
