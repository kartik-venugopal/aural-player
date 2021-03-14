import Foundation

/*
    A playback chain specifically for stopping playback.
 */
class StopPlaybackChain: PlaybackChain {
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(HaltPlaybackAction(player))
        .withAction(EndPlaybackSequenceAction(sequencer))
    }
}
