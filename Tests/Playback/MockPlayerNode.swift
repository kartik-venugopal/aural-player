import AVFoundation

class MockPlayerNode: AuralPlayerNode {
    
    private var _isPlaying: Bool = false
    
    var played: Bool = false
    var stopped: Bool = false
    var paused: Bool = false
    
    override var isPlaying: Bool {
        return _isPlaying
    }
    
    var scheduleSegment_callCount: Int = 0
    
    var scheduleSegment_session: PlaybackSession? = nil
    var scheduleSegment_startTime: Double = -1
    var scheduleSegment_endTime: Double? = -1
    
    func resetMock() {
        
        _isPlaying = false
        
        played = false
        stopped = false
        paused = false
        didReset = false
        
        scheduleSegment_callCount = 0
        
        scheduleSegment_session = nil
        scheduleSegment_startTime = -1
        scheduleSegment_endTime = -1
    }
    
    override func scheduleSegment(_ session: PlaybackSession, _ completionHandler: @escaping SessionCompletionHandler, _ startTime: Double, _ endTime: Double? = nil, _ startFrame: AVAudioFramePosition? = nil, _ immediatePlayback: Bool = true) -> PlaybackSegment? {

        scheduleSegment_callCount += 1
        
        scheduleSegment_session = session
        scheduleSegment_startTime = startTime
        scheduleSegment_endTime = endTime
        
        return nil
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
