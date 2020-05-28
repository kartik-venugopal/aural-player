import Foundation

class TestableStartPlaybackChain: StartPlaybackChain {
    
    var executionCount: Int = 0
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executionCount.increment()
        super.execute(context)
    }
    
    func reset() {
        executionCount = 0
    }
}

class TestableStopPlaybackChain: StopPlaybackChain {
    
    var executionCount: Int = 0
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executionCount.increment()
        super.execute(context)
    }
    
    func reset() {
        executionCount = 0
    }
}

class TestableTrackPlaybackCompletedChain: TrackPlaybackCompletedChain {
    
    var executionCount: Int = 0
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executionCount.increment()
        super.execute(context)
    }
    
    func reset() {
        executionCount = 0
    }
}
