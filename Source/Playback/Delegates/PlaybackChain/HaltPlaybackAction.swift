import Foundation

class HaltPlaybackAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
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
