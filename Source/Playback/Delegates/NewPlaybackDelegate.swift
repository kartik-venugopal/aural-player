import Foundation

typealias CurrentTrackState = (state: PlaybackState, track: IndexedTrack?, seekPosition: Double)

typealias TrackProducer = () -> IndexedTrack?

class NewPlaybackDelegate: PlaybackDelegate {
    
    private let startPlaybackChain: PlaybackPreparationChain = PlaybackPreparationChain()
    private let stopPlaybackChain: PlaybackPreparationChain = PlaybackPreparationChain()
    
    override init(_ appState: [PlaybackProfile], _ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ preferences: PlaybackPreferences) {
        
        super.init(appState, player, sequencer, playlist, transcoder, preferences)
        
        // Construct start playback chain
        _ = startPlaybackChain
        .withAction(CheckPlaybackAllowedAction())
        .withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(CancelWaitingOrTranscodingAction(transcoder))
        .withAction(HaltPlaybackAction(player))
        .withAction(ValidateNewTrackAction(sequencer))
        .withAction(ApplyPlaybackProfileAction(profiles, preferences))
        .withAction(SetPlaybackDelayAction(player, playlist))
        .withAction(DelayedPlaybackAction(player, sequencer, transcoder))
        .withAction(ClearGapContextAction())
        .withAction(AudioFilePreparationAction(player, sequencer, transcoder))
        .withAction(PlaybackAction(player))
        
        // Construct stop playback chain
        _ = stopPlaybackChain
        .withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(CancelWaitingOrTranscodingAction(transcoder))
        .withAction(HaltPlaybackAction(player))
        .withAction(EndPlaybackSequenceAction(sequencer))
    }
    
    override func beginPlayback() {
        doPlay({return sequencer.begin()})
    }
    
    override func playImmediately(_ track: IndexedTrack) {
        doPlay({return sequencer.begin()}, PlaybackParams().withAllowDelay(false))
    }
    
    // Plays whatever track follows the currently playing track (if there is one). If no track is playing, selects the first track in the playback sequence. Throws an error if playback fails.
    override func subsequentTrack() {
        doPlay({return sequencer.subsequent()})
    }
    
    override func previousTrack() {
        doPlay({return sequencer.previous()})
    }
    
    override func nextTrack() {
        doPlay({return sequencer.next()})
    }
    
    override func play(_ index: Int, _ params: PlaybackParams) {
        doPlay({return sequencer.select(index)}, params)
    }
    
    // TODO: If this track is already playing, just do a seek
    override func play(_ track: Track, _ params: PlaybackParams) {
        doPlay({return sequencer.select(track)}, params)
    }
    
    override func play(_ group: Group, _ params: PlaybackParams) {
        doPlay({return sequencer.select(group)}, params)
    }
    
    private func captureCurrentState() -> (state: PlaybackState, track: IndexedTrack?, seekPosition: Double) {
        
        let curTrack = state.isPlayingOrPaused ? playingTrack : (state == .waiting ? waitingTrack : playingTrack)
        return (self.state, curTrack, seekPosition.timeElapsed)
    }
    
    private func doPlay(_ trackProducer: TrackProducer, _ params: PlaybackParams = PlaybackParams.defaultParams(), _ requestedByUser: Bool = true) {
        
        let curState: CurrentTrackState = captureCurrentState()
            
        if let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext.create(curState.state, curState.track, curState.seekPosition, newTrack, requestedByUser, params)
            startPlaybackChain.execute(requestContext)
        }
    }
    
    override func stop() {
        
        let curState: CurrentTrackState = captureCurrentState()
        let requestContext = PlaybackRequestContext.create(curState.state, curState.track, curState.seekPosition, nil, true, PlaybackParams.defaultParams())
        stopPlaybackChain.execute(requestContext)
    }
}
