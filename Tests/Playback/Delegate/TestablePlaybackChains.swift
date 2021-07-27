//
//  TestablePlaybackChains.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TestablePlaybackChain: PlaybackChain {
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    
    var proceedCount: Int = 0
    var proceededContext: PlaybackRequestContext?
    
    var completionCount: Int = 0
    var completedContext: PlaybackRequestContext?
    
    var terminationCount: Int = 0
    var terminatedContext: PlaybackRequestContext?
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executedContext = context
        executionCount.increment()
        
        super.execute(context)
    }
    
    override func proceed(_ context: PlaybackRequestContext) {
        
        proceededContext = context
        proceedCount.increment()
        
        super.proceed(context)
    }
    
    override func complete(_ context: PlaybackRequestContext) {
        
        completedContext = context
        completionCount.increment()
        
        super.complete(context)
    }
    
    override func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {
        
        terminatedContext = context
        terminationCount.increment()
        
        super.terminate(context, error)
    }
    
    func reset() {
        
        executionCount = 0
        terminationCount = 0
        proceedCount = 0
        completionCount = 0

        executedContext = nil
        terminatedContext = nil
        proceededContext = nil
        completedContext = nil
    }
}

class MockPlaybackChain: PlaybackChain {
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    
    var proceedCount: Int = 0
    var proceededContext: PlaybackRequestContext?
    
    var completionCount: Int = 0
    var completedContext: PlaybackRequestContext?
    
    var terminationCount: Int = 0
    var terminatedContext: PlaybackRequestContext?
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executedContext = context
        executionCount.increment()
    }
    
    override func proceed(_ context: PlaybackRequestContext) {
        
        proceededContext = context
        proceedCount.increment()
    }
    
    override func complete(_ context: PlaybackRequestContext) {
        
        completedContext = context
        completionCount.increment()
    }
    
    override func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {
        
        terminatedContext = context
        terminationCount.increment()
    }
}

class MockPlaybackChainAction: PlaybackChainAction {
    
    var proceedAfterExecution: Bool
    
    var executionCount: Int = 0
    var executedContext: PlaybackRequestContext?
    var executionTimestamp: TimeInterval?
    
    init(_ proceedAfterExecution: Bool) {
        self.proceedAfterExecution = proceedAfterExecution
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        executionTimestamp = ProcessInfo.processInfo.systemUptime
     
        executedContext = context
        executionCount.increment()
        
        // Simulate some work being done
        usleep(5000)
        
        if proceedAfterExecution {
            chain.proceed(context)
        }
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
    
    var proceedCount: Int = 0
    var proceededContext: PlaybackRequestContext?
    
    var completionCount: Int = 0
    var completedContext: PlaybackRequestContext?
    
    var terminationCount: Int = 0
    var terminatedContext: PlaybackRequestContext?
    
    override func execute(_ context: PlaybackRequestContext) {
        
        executedContext = context
        executionCount.increment()
        
        super.execute(context)
    }
    
    override func proceed(_ context: PlaybackRequestContext) {
        
        proceededContext = context
        proceedCount.increment()
        
        super.proceed(context)
    }
    
    override func complete(_ context: PlaybackRequestContext) {
        
        completedContext = context
        completionCount.increment()
        
        super.complete(context)
    }
    
    override func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {
        
        terminatedContext = context
        terminationCount.increment()
        
        super.terminate(context, error)
    }
    
    func reset() {
        
        executionCount = 0
        terminationCount = 0
        proceedCount = 0
        completionCount = 0

        executedContext = nil
        terminatedContext = nil
        proceededContext = nil
        completedContext = nil
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
