import Foundation

class HaltPlaybackAction: PlaybackPreparationAction {
    
    var nextAction: PlaybackPreparationAction?
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        if context.currentState != .noTrack {
            player.stop()
        }
        
        nextAction?.execute(context)
    }
}
