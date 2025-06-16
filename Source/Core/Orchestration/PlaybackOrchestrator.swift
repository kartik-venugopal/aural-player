//
// PlaybackOrchestrator.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
//

import Foundation

class PlaybackOrchestrator: PlaybackOrchestratorProtocol {
    
    private let player: PlayerProtocol
    private let playQueue: PlayQueueProtocol
    
    private lazy var startPlaybackChain: StartPlaybackChain = StartPlaybackChain(playerPlayFunction: player.play(track:params:),
                                                                                 playerStopFunction: player.stop,
                                                                                 playQueue: playQueue,
                                                                                 trackReader: trackReader,
                                                                                 preferences.playbackPreferences)
    
    private lazy var stopPlaybackChain: StopPlaybackChain = StopPlaybackChain(playerStopFunction: player.stop,
                                                                              playQueue: playQueue,
                                                                              preferences: preferences.playbackPreferences)
    
    /// A "producer" (or factory) function that produces an optional Track (used when deciding which track will play next).
    fileprivate typealias TrackProducer = () -> Track?
    
    init(player: PlayerProtocol, playQueue: PlayQueueProtocol) {
        
        self.player = player
        self.playQueue = playQueue
    }
    
    func togglePlayPause() -> PlaybackCommandResult {
        
        // Determine current state of player, to then toggle it
        switch state {
            
        case .stopped:
            beginPlayback()
            
        case .paused:
            resume()
            
        case .playing:
            pause()
        }
        
        return currentStateAsCommandResult
    }
    
    private func beginPlayback() {
        
        doPlay(withParams: .defaultParams){
            playQueue.start()
        }
    }
    
    private func pause() {
        player.pause()
    }
    
    private func resume() {
        player.resume()
    }
    
    func previousTrack() -> PlaybackCommandResult {
        
        doPlay {playQueue.previous()}
        return currentStateAsCommandResult
    }
    
    func nextTrack() -> PlaybackCommandResult {
        
        doPlay {playQueue.next()}
        return currentStateAsCommandResult
    }
    
    // Captures the current player state and proceeds with playback according to the playback sequence
    private func doPlay(withParams params: PlaybackParams = .defaultParams, trackProducer: TrackProducer) {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = player.seekPosition.timeElapsed
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
        
        if okToPlay, let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, params)
            startPlaybackChain.execute(requestContext)
        }
    }
    
    var state: PlaybackState {
        player.state
    }
    
    var playbackPosition: PlaybackPosition? {
        player.seekPosition
    }
    
    var playingTrack: Track? {
        player.playingTrack
    }
    
    var currentStateAsCommandResult: PlaybackCommandResult {
        
        guard let playingTrack = self.playingTrack,
              let playbackPosition = self.playbackPosition else {
            
            return .noTrack
        }
        
        return PlaybackCommandResult(state: state,
                                     playingTrackInfo: PlayingTrackInfo(track: playingTrack,
                                                                        playbackPosition: playbackPosition,
                                                                        playingChapterTitle: player.playingChapter?.track.title))
    }
}
