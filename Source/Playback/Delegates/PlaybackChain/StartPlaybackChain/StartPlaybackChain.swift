import Foundation

// A playback chain specifically for starting playback of a specific track.
class StartPlaybackChain: PlaybackChain {
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        super.init()
        
        _ = self.withAction(CheckPlaybackAllowedAction())
        .withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(CancelWaitingOrTranscodingAction(transcoder))
        .withAction(HaltPlaybackAction(player))
        .withAction(ValidateNewTrackAction(sequencer))
        .withAction(ApplyPlaybackProfileAction(profiles, preferences))
        .withAction(SetPlaybackDelayAction(player, playlist))
        .withAction(DelayedPlaybackAction(player, sequencer, transcoder))
        .withAction(ClearGapContextAction())
        .withAction(AudioFilePreparationAction(player, sequencer, transcoder))
        .withAction(StartPlaybackAction(player))
    }
}
