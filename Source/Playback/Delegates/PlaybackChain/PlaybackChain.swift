import Foundation

class PlaybackChain {
    
    private(set) var actions: [PlaybackChainAction] = []
    
    func withAction(_ action: PlaybackChainAction) -> PlaybackChain {
        
        var lastAction = actions.last
        actions.append(action)
        lastAction?.nextAction = action
        
        return self
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        PlaybackRequestContext.begun(context)
        actions.first?.execute(context)
    }
}

protocol PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext)

    // The next action in the playback chain. Will be executed by this action object,
    // if execution of this object's action was completed successfully and further execution
    // of the playback chain has not been deferred.
    var nextAction: PlaybackChainAction? {get set}
}
