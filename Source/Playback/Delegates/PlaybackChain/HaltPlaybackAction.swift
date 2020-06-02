import Foundation

class HaltPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if context.currentState != .noTrack {
            player.stop()
        }
        
        chain.proceed(context)
    }
}
