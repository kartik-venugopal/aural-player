import Foundation

class PlaybackChain {
    
    private(set) var actions: [PlaybackChainAction] = []
    private var actionIndex: Int = -1
    
    func withAction(_ action: PlaybackChainAction) -> PlaybackChain {
        
        actions.append(action)
        return self
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        actionIndex = -1
        PlaybackRequestContext.begun(context)
        proceed(context)
    }
    
    func proceed(_ context: PlaybackRequestContext) {
        
        actionIndex.increment()
        
        if actionIndex < actions.count {
            actions[actionIndex].execute(context, self)
            
        } else {
            complete(context)
        }
    }
    
    func terminate(_ context: PlaybackRequestContext, _ error: InvalidTrackError) {
        complete(context)
    }
    
    func complete(_ context: PlaybackRequestContext) {
        PlaybackRequestContext.completed(context)
    }
}

protocol PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain)
}
