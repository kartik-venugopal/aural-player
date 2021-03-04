import Foundation

/*
    A PlaybackChain that starts playback of a specific track.
    It is composed of several actions that perform any required
    pre-processing or notifications.
 */
class StartPlaybackChain: PlaybackChain, NotificationSubscriber {

    private let player: PlayerProtocol
    private let sequencer: SequencerProtocol
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, trackReader: TrackReader, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(HaltPlaybackAction(player))
        .withAction(ValidateNewTrackAction())
        .withAction(ApplyPlaybackProfileAction(profiles, preferences))
        .withAction(AudioFilePreparationAction(player: player, trackReader: trackReader))
        .withAction(StartPlaybackAction(player))
        
//        Messenger.subscribeAsync(self, .transcoder_finished, self.transcodingFinished(_:), queue: .main)
    }
    
    // Halts playback and ends the playback sequence when an error is encountered.
    override func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {

        player.stop()
        sequencer.end()

        // Notify observers of the error, and complete the request context.
        Messenger.publish(TrackNotPlayedNotification(oldTrack: context.currentTrack, error: error))
        complete(context)
    }
    
    // Responds when transcoding for a track has finished.
    // Either proceeds with playback, or terminates the chain, depending on
    // transcoding success/failure.
//    func transcodingFinished(_ notification: TranscodingFinishedNotification) {
//
//        // Match the transcoded track to that from the deferred (i.e. current) request context.
//        if let currentContext = PlaybackRequestContext.currentContext, notification.track == currentContext.requestedTrack {
//
//            // Proceed with playback if transcoding was successful.
//            if notification.success {
//
//                proceed(currentContext)
//            }
//
////            } else if let error = notification.track.lazyLoadingInfo.preparationError {
////
////                terminate(currentContext, error)
////            }
//        }
//    }
}
