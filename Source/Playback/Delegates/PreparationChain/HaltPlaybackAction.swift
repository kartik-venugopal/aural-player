import Foundation

class HaltPlaybackAction: PlaybackPreparationAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        if context.currentState != .noTrack {
            player.stop()
        }
        
        return true
    }
}
