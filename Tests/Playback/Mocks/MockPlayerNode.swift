import AVFoundation

class MockPlayerNode: AuralPlayerNode {
    
    private var _isPlaying: Bool = false
    
    var played: Bool = false
    var stopped: Bool = false
    var paused: Bool = false
    
    override var isPlaying: Bool {
        return _isPlaying
    }
    
    var _seekPosition: Double = 0
    override var seekPosition: Double {
        return _seekPosition
    }
    
    var scheduleSegment_callCount: Int = 0
    
    var scheduleSegment_session: PlaybackSession? = nil
    var scheduleSegment_startTime: Double? = nil
    var scheduleSegment_endTime: Double? = nil
    
    func resetMock() {
        
        _isPlaying = false
        
        played = false
        stopped = false
        paused = false
        didReset = false
        
        _seekPosition = 0
        
        scheduleSegment_callCount = 0
        
        scheduleSegment_session = nil
        scheduleSegment_startTime = nil
        scheduleSegment_endTime = nil
    }
    
    override func scheduleSegment(_ session: PlaybackSession, _ completionHandler: @escaping SessionCompletionHandler, _ startTime: Double, _ endTime: Double? = nil, _ startFrame: AVAudioFramePosition? = nil, _ immediatePlayback: Bool = true) -> PlaybackSegment? {

        scheduleSegment_callCount += 1
        
        scheduleSegment_session = session
        scheduleSegment_startTime = startTime
        scheduleSegment_endTime = endTime
        
        // Dummy segment
        return PlaybackSegment(session, AVAudioFile(), AVAudioFramePosition(startTime * 44100), AVAudioFramePosition(session.track.duration * 44100), AVAudioFrameCount((session.track.duration - startTime) * 44100), startTime, endTime ?? session.track.duration)
    }
    
    override func scheduleSegment(_ segment: PlaybackSegment, _ completionHandler: @escaping SessionCompletionHandler, _ immediatePlayback: Bool = true) {
        
        scheduleSegment_callCount += 1
        
        scheduleSegment_session = segment.session
        scheduleSegment_startTime = segment.startTime
        scheduleSegment_endTime = segment.endTime
    }
    
    override func play() {
        
        _isPlaying = true
        played = true
    }
    
    override func stop() {
        
        _isPlaying = false
        stopped = true
    }
    
    override func pause() {
        
        _isPlaying = false
        paused = true
    }
    
    var didReset: Bool = false
    
    override func reset() {
        didReset = true
    }
}
