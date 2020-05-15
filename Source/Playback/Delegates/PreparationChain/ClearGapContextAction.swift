import Foundation

class ClearGapContextAction: PlaybackPreparationAction {
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        // Invalidate the gap, if there is one
        PlaybackGapContext.clear()
        return true
    }
}
