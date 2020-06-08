import Foundation

/*
    A PlaybackChain that starts playback of a specific track.
    It is composed of several actions that perform any required
    pre-processing or notifications.
 */
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
        .withAction(AudioFilePreparationAction(player, transcoder))
        .withAction(StartPlaybackAction(player))
        
        AsyncMessenger.subscribe([.transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    // Halts playback and ends the playback sequence when an error is encountered.
    override func terminate(_ context: PlaybackRequestContext, _ error: InvalidTrackError) {

        player.stop()
        sequencer.end()

        // Notify observers of the error, and complete the request context.
        AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, error))
        complete(context)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
       
        if let transcodingFinishedMsg = message as? TranscodingFinishedAsyncMessage {
            
            transcodingFinished(transcodingFinishedMsg)
            return
        }
    }
    
    // Responds when transcoding for a track has finished.
    // Either proceeds with playback, or terminates the chain, depending on
    // transcoding success/failure.
    private func transcodingFinished(_ msg: TranscodingFinishedAsyncMessage) {
        
        // Match the transcoded track to that from the deferred (i.e. current) request context.
        if let currentContext = PlaybackRequestContext.currentContext, msg.track == currentContext.requestedTrack {

            // Make sure there is no delay (i.e. state != waiting) before proceeding.
            if player.state != .waiting && msg.success {

                proceed(currentContext)
                
            } else if !msg.success, let error = msg.track.lazyLoadingInfo.preparationError {
                
                terminate(currentContext, error)
            }
        }
    }
}
