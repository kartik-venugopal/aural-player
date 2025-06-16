//
// PlaybackOrchestrator+Play.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlaybackOrchestrator {
    
    /// A "producer" (or factory) function that produces an optional Track (used when deciding which track will play next).
    fileprivate typealias TrackProducer = () -> Track?
    
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
        
        guard doPlay(trackProducer: {playQueue.start()}) else {return}
        
        ui?.playingTrackChanged(newTrack: self.playingTrack)
        ui?.playbackStateChanged(newState: self.state)
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
    }
    
    private func pause() {
        
        player.pause()
        ui?.playbackStateChanged(newState: self.state)
    }
    
    private func resume() {
        
        player.resume()
        ui?.playbackStateChanged(newState: self.state)
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
    }
    
    func resumeIfPaused() {
        
        if state == .paused {
            resume()
        }
    }
    
    func replayTrack() -> PlaybackCommandResult {
        
        if state.isPlayingOrPaused {
            
            player.seek(to: 0, canSeekOutsideLoop: true)
            resumeIfPaused()
        }
        
        return currentStateAsCommandResult
    }
    
    func previousTrack() -> PlaybackCommandResult {
        
        if doPlay(trackProducer: {playQueue.previous()}) {
            
            ui?.playingTrackChanged(newTrack: self.playingTrack)
            ui?.playbackStateChanged(newState: self.state)
            ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        }
        
        return currentStateAsCommandResult
    }
    
    func nextTrack() -> PlaybackCommandResult {
        
        if doPlay(trackProducer: {playQueue.next()}) {
            
            ui?.playingTrackChanged(newTrack: self.playingTrack)
            ui?.playbackStateChanged(newState: self.state)
            ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        }
        
        return currentStateAsCommandResult
    }
    
    // Captures the current player state and proceeds with playback according to the playback sequence
    private func doPlay(withParams params: PlaybackParams = .defaultParams, trackProducer: TrackProducer) -> Bool {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = player.seekPosition.timeElapsed
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
        
        guard okToPlay, let newTrack = trackProducer() else {return false}
        
        let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, requestParams: params)
        startPlaybackChain.execute(requestContext)
        
        return true
    }
    
    func stop() -> PlaybackCommandResult {
        
        doStop()
        
        ui?.playingTrackChanged(newTrack: self.playingTrack)
        ui?.playbackStateChanged(newState: self.state)
        
        return currentStateAsCommandResult
    }
    
    // theCurrentTrack points to the (precomputed) current track before this stop operation.
    // It is required because sometimes, the sequence will have been cleared before stop() is called,
    // making it impossible to capture the current track before stopping playback.
    // If nil, the current track can be computed normally (by calling playingTrack).
    func doStop(_ theCurrentTrack: Track? = nil) {
        
        let stateBeforeChange = state
        guard stateBeforeChange.isPlayingOrPaused else {return}
        
        let trackBeforeChange = theCurrentTrack ?? playingTrack
        let seekPositionBeforeChange = playbackPosition?.timeElapsed ?? 0
        
        let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil)
        stopPlaybackChain.execute(requestContext)
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
