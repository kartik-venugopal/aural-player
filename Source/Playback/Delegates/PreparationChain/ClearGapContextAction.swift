import Foundation

class ClearGapContextAction: PlaybackPreparationAction {
    
    var nextAction: PlaybackPreparationAction?
    
    func execute(_ context: PlaybackRequestContext) {
        
        // Invalidate the gap, if there is one
        PlaybackGapContext.clear()
        nextAction?.execute(context)
    }
}
