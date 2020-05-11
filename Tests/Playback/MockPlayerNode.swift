import AVFoundation

class MockPlayerNode: AVAudioPlayerNode {
    
    private var _isPlaying: Bool = false
    
    var played: Bool = false
    var stopped: Bool = false
    var paused: Bool = false
    
    override var isPlaying: Bool {
        return _isPlaying
    }
    
    var scheduledSegmentInvoked: Bool = false
    var scheduledSegment_startFrame: AVAudioFramePosition = 0
    var scheduledSegment_frameCount: AVAudioFrameCount = 0
    
    override func scheduleSegment(_ file: AVAudioFile, startingFrame startFrame: AVAudioFramePosition, frameCount numberFrames: AVAudioFrameCount, at when: AVAudioTime?, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        
        scheduledSegmentInvoked = true
        scheduledSegment_startFrame = startFrame
        scheduledSegment_frameCount = numberFrames
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
    
    func resetMock() {
        
        _isPlaying = false
        
        played = false
        stopped = false
        paused = false
        didReset = false
        
        scheduledSegmentInvoked = false
        scheduledSegment_startFrame = 0
        scheduledSegment_frameCount = 0
    }
}
