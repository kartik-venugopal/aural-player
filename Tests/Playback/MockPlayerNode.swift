import AVFoundation

class MockPlayerNode: AVAudioPlayerNode {
    
    private var _isPlaying: Bool = false
    
    override var isPlaying: Bool {
        return _isPlaying
    }
    
    var scheduledSegment_startFrame: AVAudioFramePosition = 0
    var scheduledSegment_frameCount: AVAudioFrameCount = 0
    
    override func scheduleSegment(_ file: AVAudioFile, startingFrame startFrame: AVAudioFramePosition, frameCount numberFrames: AVAudioFrameCount, at when: AVAudioTime?, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        
        scheduledSegment_startFrame = startFrame
        scheduledSegment_frameCount = numberFrames
    }
    
    override func play() {
        _isPlaying = true
    }
    
    override func stop() {
        _isPlaying = false
    }
    
    override func pause() {
        _isPlaying = false
    }
    
    var hasBeenReset: Bool = false
    
    override func reset() {
        hasBeenReset = true
    }
    
    func resetMock() {
        
        _isPlaying = false
        scheduledSegment_startFrame = 0
        scheduledSegment_frameCount = 0
    }
}
