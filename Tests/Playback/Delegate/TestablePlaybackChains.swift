import Foundation

class TestableStartPlaybackChain: StartPlaybackChain {
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executedContext = context
        executionCount.increment()
        super.execute(context)
    }
    
    func reset() {
        executionCount = 0
        executedContext = nil
    }
}

class TestableStopPlaybackChain: StopPlaybackChain {
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executedContext = context
        executionCount.increment()
        super.execute(context)
    }
    
    func reset() {
        executionCount = 0
        executedContext = nil
    }
}

class TestableTrackPlaybackCompletedChain: TrackPlaybackCompletedChain {
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executedContext = context
        executionCount.increment()
        super.execute(context)
    }
    
    func reset() {
        executionCount = 0
        executedContext = nil
    }
}
