import Foundation

class PlaybackAction: PlaybackPreparationAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        guard let newTrack = context.requestedTrack else {return false}
        
        let oldTrack = context.currentTrack
        let params = context.requestParams
        
        SyncMessenger.publishNotification(PreTrackChangeNotification(oldTrack, context.currentState, newTrack))
        
        player.play(newTrack.track, params.startPosition ?? 0, params.endPosition)
        
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, context.currentState, newTrack))
        
        return true
    }
}
