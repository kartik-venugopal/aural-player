import Foundation

// A playback chain specifically for starting playback of a specific track.
class StartPlaybackChain: PlaybackChain {
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(CancelTranscodingAction(transcoder))
        .withAction(ValidateNewTrackAction(sequencer))
        .withAction(ApplyPlaybackProfileAction(profiles, preferences))
        .withAction(SetPlaybackDelayAction(player, playlist))
        .withAction(DelayedPlaybackAction(player, sequencer, transcoder))
        .withAction(AudioFilePreparationAction(player, sequencer, transcoder))
        .withAction(StartPlaybackAction(player))
    }
}
