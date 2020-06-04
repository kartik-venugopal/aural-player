import Foundation

// A playback chain specifically for starting playback of a specific track.
class StartPlaybackChain: PlaybackChain, AsyncMessageSubscriber {

    private let player: PlayerProtocol
    private let sequencer: SequencerProtocol
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(CancelTranscodingAction(transcoder))
        .withAction(HaltPlaybackAction(player))
        .withAction(ValidateNewTrackAction())
        .withAction(ApplyPlaybackProfileAction(profiles, preferences))
        .withAction(SetPlaybackDelayAction(playlist))
        .withAction(AudioFilePreparationAction(player, sequencer, transcoder))
        .withAction(StartPlaybackAction(player))
        
        AsyncMessenger.subscribe([.transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    override func terminate(_ context: PlaybackRequestContext, _ error: InvalidTrackError) {

        // End the playback sequence
        sequencer.end()
        
        AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, error))
        
        complete(context)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
       
        if let transcodingFinishedMsg = message as? TranscodingFinishedAsyncMessage {
            
            transcodingFinished(transcodingFinishedMsg)
            return
        }
    }
    
    private func transcodingFinished(_ msg: TranscodingFinishedAsyncMessage) {
        
        // Make sure there is no delay (i.e. state != waiting) before acting on this message.
        // And match the transcoded track to that from the deferred request context.
        
        if let currentContext = PlaybackRequestContext.currentContext, msg.track == currentContext.requestedTrack {
            
            if player.state != .waiting && msg.success {
                
                // Transcoding succeeded, proceed with the playback chain.
                proceed(currentContext)
                
            } else if !msg.success, let error = msg.track.lazyLoadingInfo.preparationError {
                
                // Transcoding failed, terminate the chain
                terminate(currentContext, error)
            }
        }
    }
}
