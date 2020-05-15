import Foundation

class PlaybackPreparationChain {
    
    var actions: [PlaybackPreparationAction] = []
    
    func withAction(_ action: PlaybackPreparationAction) -> PlaybackPreparationChain {
        
        actions.append(action)
        return self
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        for action in actions {
            
            // Execute the action and check if it is ok to proceed with the chain.
            if !action.execute(context) {break}
        }
    }
}

protocol PlaybackPreparationAction {
    
    // Returns whether or not the chain should proceed with execution.
    func execute(_ context: PlaybackRequestContext) -> Bool
}

protocol PlaybackPreparationCompositeAction: PlaybackPreparationAction {
    
    var actions: [PlaybackPreparationAction] {get}
}

class PlaybackRequestContext {
    
    // Current state can change (if waiting or transcoding before playback)
    var currentState: PlaybackState
    
    let currentTrack: IndexedTrack?
    let currentSeekPosition: Double

    // TODO: Can this be nil ???
    let requestedTrack: IndexedTrack?
    
    let requestedByUser: Bool
    
    // Request params may change as the preparation chain executes.
    var requestParams: PlaybackParams
    
    var gapContextId: Int?

    init(_ currentState: PlaybackState, _ currentTrack: IndexedTrack?, _ currentSeekPosition: Double, _ requestedTrack: IndexedTrack?, _ requestedByUser: Bool, _ requestParams: PlaybackParams) {
        
        self.currentState = currentState
        self.currentTrack = currentTrack
        self.currentSeekPosition = currentSeekPosition
        
        self.requestedTrack = requestedTrack
        self.requestedByUser = requestedByUser
        self.requestParams = requestParams
        
        self.gapContextId = nil
    }
}
