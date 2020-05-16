import Foundation

class PlaybackChain {
    
    var actions: [PlaybackChainAction] = []
    
    func withAction(_ action: PlaybackChainAction) -> PlaybackChain {
        
        var lastAction = actions.last
        actions.append(action)
        lastAction?.nextAction = action
        
        return self
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        context.begun()
        
        if let firstAction = actions.first {
            firstAction.execute(context)
        }
    }
}

protocol PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext)

    // The next action in the playback chain. Will be executed by this action object,
    // if execution of this object's action was completed successfully and further execution
    // of the playback chain has not been deferred.
    var nextAction: PlaybackChainAction? {get set}
}

// A playback chain specifically for starting playback of a specific track.
class StartPlaybackChain: PlaybackChain {
    
    let player: PlayerProtocol
    let sequencer: PlaybackSequencerProtocol
    let playlist: PlaylistCRUDProtocol
    let transcoder: TranscoderProtocol
    
    let profiles: PlaybackProfiles
    let preferences: PlaybackPreferences
    
    init(_ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        self.playlist = playlist
        self.transcoder = transcoder
        
        self.profiles = profiles
        self.preferences = preferences
        
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

// A playback chain specifically for stopping playback.
class StopPlaybackChain: PlaybackChain {
    
    let player: PlayerProtocol
    let sequencer: PlaybackSequencerProtocol
    let transcoder: TranscoderProtocol
    
    let profiles: PlaybackProfiles
    let preferences: PlaybackPreferences
    
    init(_ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ transcoder: TranscoderProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder
        
        self.profiles = profiles
        self.preferences = preferences
        
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(CancelWaitingOrTranscodingAction(transcoder))
        .withAction(HaltPlaybackAction(player))
        .withAction(EndPlaybackSequenceAction(sequencer))
    }
}
