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
    
    let player: PlayerProtocol
    let playQueue: PlayQueueProtocol
    let playbackPreferences: PlaybackPreferences
    
    lazy var startPlaybackChain: StartPlaybackChain = StartPlaybackChain(playerPlayFunction: player.play(track:params:),
                                                                                 playerStopFunction: player.stop,
                                                                                 playQueue: playQueue,
                                                                                 trackReader: trackReader,
                                                                                 preferences.playbackPreferences)
    
    lazy var stopPlaybackChain: StopPlaybackChain = StopPlaybackChain(playerStopFunction: player.stop,
                                                                              playQueue: playQueue,
                                                                              preferences: preferences.playbackPreferences)
    
    lazy var trackPlaybackCompletedChain: TrackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain)
    
    var ui: PlaybackUI?
    
    init(playerNode: AuralPlayerNode, playQueue: PlayQueueProtocol, playbackPreferences: PlaybackPreferences) {
        
        self.player = DiscretePlayer(playerNode: playerNode)
        self.playQueue = playQueue
        self.playbackPreferences = playbackPreferences
    }
    
    func registerUI(ui: any PlaybackUI) {
        self.ui = ui
    }
    
    func deregisterUI(ui: any PlaybackUI) {
        
        if ui.id == self.ui?.id {
            self.ui = nil
        }
    }
    
    var state: PlaybackState {
        player.state
    }
    
    var isPlaying: Bool {
        state.isPlaying
    }
    
    var playbackPosition: PlaybackPosition? {
        player.seekPosition
    }
    
    var playingTrack: Track? {
        player.playingTrack
    }
    
    var playbackLoop: PlaybackLoop? {
        player.playbackLoop
    }
    
    var playbackLoopState: PlaybackLoopState {
        player.playbackLoopState
    }
}
