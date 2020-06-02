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
        
        let oldTrack = context.currentTrack
        let params = context.requestParams
        
        SyncMessenger.publishNotification(PreTrackChangeNotification(oldTrack, context.currentState, newTrack))
        
        player.play(newTrack, params.startPosition ?? 0, params.endPosition)
        
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, context.currentState, newTrack))
        
        chain.proceed(context)
    }
}
