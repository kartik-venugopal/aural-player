import Foundation

class StartPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        if context.currentTrack != context.requestedTrack {
            SyncMessenger.publishNotification(PreTrackChangeNotification(context.currentTrack, context.currentState, newTrack))
        }
        
        player.play(newTrack, context.requestParams.startPosition ?? 0, context.requestParams.endPosition)
        
        AsyncMessenger.publishMessage(TrackTransitionAsyncMessage(context.currentTrack, context.currentState, context.requestedTrack, .playing))
        
        chain.complete(context)
    }
}
