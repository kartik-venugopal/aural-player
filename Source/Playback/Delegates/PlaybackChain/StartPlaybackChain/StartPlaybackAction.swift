import Foundation

/*
    Actually starts playback of a requested track, after all the necessary pre-processing has been completed.
    This is the terminal (last) action in a StartPlaybackChain.
 */
class StartPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Cannot proceed if no requested track is specified.
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, NoRequestedTrackError.instance)
            return
        }
        
        // Publish a pre-track-change notification for observers who need to perform actions before the track changes.
        // e.g. applying audio settings/effects.
        if context.currentTrack != context.requestedTrack {
            Messenger.publish(PreTrackChangeNotification(oldTrack: context.currentTrack, oldState: context.currentState, newTrack: newTrack))
        }
        
        // Start playback
        player.play(newTrack, context.requestParams.startPosition ?? 0, context.requestParams.endPosition)
        
        // Inform observers of the track change/transition.
        Messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: context.requestedTrack, endState: .playing))
        
        // Mark the playback chain as having completed execution.
        chain.complete(context)
    }
}
