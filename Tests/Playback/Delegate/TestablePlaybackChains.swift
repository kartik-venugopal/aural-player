import Foundation

class TestablePlaybackChain: PlaybackChain {
    
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

class MockPlaybackChainAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    var executionTimestamp: TimeInterval?
    
    func execute(_ context: PlaybackRequestContext) {
        
        executionTimestamp = ProcessInfo.processInfo.systemUptime
     
        executedContext = context
        executionCount.increment()
        
        nextAction?.execute(context)
    }
}

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
