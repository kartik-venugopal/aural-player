import Foundation

/*
    Implements the "chain of responsibility" design pattern.
    Performs a sequence (or "chain") of actions related to playback (e.g. stopping/starting playback).
 */
class PlaybackChain {
    
    // The (ordered) actions that constitute the "links" of the "chain"
    private(set) var actions: [PlaybackChainAction] = []
    
    // The index of the currently executing action within the chain.
    // NOTE: An index of -1 denotes that the chain has not yet started execution.
    private var actionIndex: Int = -1
    
    // Builder pattern function to append a single action to the chain.
    func withAction(_ action: PlaybackChainAction) -> PlaybackChain {
        
        actions.append(action)
        return self
    }
    
    // Begins execution of a playback request.
    // The context parameter contains all request information required to perform the actions in the chain.
    func execute(_ context: PlaybackRequestContext) {
        
        actionIndex = -1
        PlaybackRequestContext.begun(context)
        proceed(context)
    }
    
    // Executes the next action in the chain.
    func proceed(_ context: PlaybackRequestContext) {
        
        actionIndex.increment()
        
        if actionIndex < actions.count {
            
            // Execute the next action.
            actions[actionIndex].execute(context, self)
            
        } else {
            
            // Reached the end of the chain. Mark the context as completed.
            complete(context)
        }
    }
    
    // (Abruptly) terminates the chain, with an error.
    func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {
        complete(context)
    }
    
    // Marks the request context as complete (after execution or abrupt termination).
    func complete(_ context: PlaybackRequestContext) {
        PlaybackRequestContext.completed(context)
    }
}

// Protocol for a single action that is part of a PlaybackChain.
protocol PlaybackChainAction {
    
    // Executes this action according to the given request parameters.
    // The chain is a reference to the parent PlaybackChain.
    // It can be used to:
    // 1 - Proceed with execution (of the next action in the chain).
    // 2 - Signal completion of the chain.
    // 3 - Signal abrupt termination of the chain.
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain)
}
