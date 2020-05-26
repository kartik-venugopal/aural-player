import Foundation

class TestableStartPlaybackChain: StartPlaybackChain {
    
    var executionCount: Int = 0
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executionCount.increment()
        super.execute(context)
    }
}

class TestableStopPlaybackChain: StopPlaybackChain {
    
    var executionCount: Int = 0
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executionCount.increment()
        super.execute(context)
    }
}

class TestableTrackPlaybackCompletedChain: TrackPlaybackCompletedChain {
    
    var executionCount: Int = 0
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executionCount.increment()
        super.execute(context)
    }
}
