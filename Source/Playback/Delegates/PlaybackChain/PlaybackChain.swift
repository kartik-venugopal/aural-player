import Foundation

class PlaybackChain {
    
    private(set) var actions: [PlaybackChainAction] = []
    private(set) var actionIndex: Int = -1
    
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
            executeAction(actions[actionIndex], context)
            
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
    
    private func executeAction(_ action: PlaybackChainAction, _ context: PlaybackRequestContext) {
        action.execute(context, self)
    }
}

protocol PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain)
}
