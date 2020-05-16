import Foundation

typealias CurrentTrackState = (state: PlaybackState, track: Track?, seekPosition: Double)

typealias TrackProducer = () -> IndexedTrack?

class NewPlaybackDelegate: PlaybackDelegate {
    
    private var startPlaybackChain: PlaybackChain = PlaybackChain()
    private var stopPlaybackChain: PlaybackChain = PlaybackChain()
    private var trackPlaybackCompletedChain: PlaybackChain = PlaybackChain()
    
    override init(_ appState: [PlaybackProfile], _ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ preferences: PlaybackPreferences) {
        
        super.init(appState, player, sequencer, playlist, transcoder, preferences)
        
        self.profiles = PlaybackProfiles()
        appState.forEach({profiles.add($0.file, $0)})
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.savePlaybackProfile, .deletePlaybackProfile], subscriber: self)
        AsyncMessenger.subscribe([.playbackCompleted, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        startPlaybackChain = StartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
        stopPlaybackChain = StopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
        trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain as! StartPlaybackChain, stopPlaybackChain as! StopPlaybackChain, sequencer, playlist, profiles, preferences)
    }
    
    override func beginPlayback() {
        doPlay({return sequencer.begin()}, PlaybackParams.defaultParams(), false)
    }
    
    override func playImmediately(_ track: IndexedTrack) {
        doPlay({return sequencer.begin()}, PlaybackParams().withAllowDelay(false))
    }
    
    // Plays whatever track follows the currently playing track (if there is one). If no track is playing, selects the first track in the playback sequence. Throws an error if playback fails.
    override func subsequentTrack() {
        doPlay({return sequencer.subsequent()}, PlaybackParams.defaultParams(), false)
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
    
    override func play(_ track: Track, _ params: PlaybackParams) {
        doPlay({return sequencer.select(track)}, params)
    }
    
    override func play(_ group: Group, _ params: PlaybackParams) {
        doPlay({return sequencer.select(group)}, params)
    }
    
    private func captureCurrentState() -> (state: PlaybackState, track: Track?, seekPosition: Double) {
        
        let curTrack = state.isPlayingOrPaused ? playingTrack : (state == .waiting ? waitingTrack : playingTrack)
        return (self.state, curTrack?.track, seekPosition.timeElapsed)
    }
    
    private func doPlay(_ trackProducer: TrackProducer, _ params: PlaybackParams = PlaybackParams.defaultParams(), _ cancelWaitingOrTranscoding: Bool = true) {
        
        let curState: CurrentTrackState = captureCurrentState()
            
        if let newTrack = trackProducer() {
            
            print("\nGoing to play:", newTrack.track.conciseDisplayName)
            
            let requestContext = PlaybackRequestContext.create(curState.state, curState.track, curState.seekPosition, newTrack.track, cancelWaitingOrTranscoding, params)
            
            print("\tRequest Context:", requestContext.toString())
            
            startPlaybackChain.execute(requestContext)
        }
    }
    
    override func stop() {
        
        let curState: CurrentTrackState = captureCurrentState()
        let requestContext = PlaybackRequestContext.create(curState.state, curState.track, curState.seekPosition, nil, true, PlaybackParams.defaultParams())
        
        stopPlaybackChain.execute(requestContext)
    }
    
    override func trackPlaybackCompleted() {
        
        let curState: CurrentTrackState = captureCurrentState()
        let requestContext = PlaybackRequestContext.create(curState.state, curState.track, curState.seekPosition, nil, false, PlaybackParams.defaultParams())
        
        trackPlaybackCompletedChain.execute(requestContext)
    }
}
