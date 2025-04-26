//
// DiscretePlayer+Play.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    ///
    /// A "producer" (or factory) function that produces an optional Track (used when deciding which track will play next).
    ///
    fileprivate typealias TrackProducer = () -> Track?
    
    func togglePlayPause() {
        
        // Determine current state of player, to then toggle it
        switch state {
            
        case .stopped:
            
            beginPlayback()
            
        case .paused:
            
            resume()
            
        case .playing:
            
            pause()
        }
    }
    
    private func beginPlayback() {
        initiatePlayback(playQueue.start)
    }
    
    func play(trackAtIndex index: Int, params: PlaybackParams) {
        
        initiatePlayback({
            playQueue.select(trackAt: index)
        }, params)
    }
    
    func play(track: Track, params: PlaybackParams) {
        
        initiatePlayback({
            playQueue.selectTrack(track)
        }, params)
    }
    
    func playNow(tracks: [Track], clearQueue: Bool, params: PlaybackParams) -> IndexSet {
        
        let indices = playQueue.enqueueTracks(tracks, clearQueue: clearQueue)
        
        if let trackToPlay = tracks.first {
            play(track: trackToPlay, params: params)
        }
        
        return indices
    }
    
    func previousTrack() {
        
        if state.isPlayingOrPaused {
            initiatePlayback(playQueue.previous)
        }
    }
    
    func nextTrack() {
        
        if state.isPlayingOrPaused {
            initiatePlayback(playQueue.next)
        }
    }
    
    func resumeShuffleSequence(with track: Track, atPosition position: TimeInterval) {
        
        initiatePlayback({
            playQueue.resumeShuffleSequence(with: track)
        }, .init().withStartAndEndPosition(position))
    }
    
    // Captures the current player state and proceeds with playback according to the playback sequence
    private func initiatePlayback(_ trackProducer: TrackProducer, _ params: PlaybackParams = .defaultParams()) {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = playerPosition
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
        
        if okToPlay, let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, params)
            startPlaybackChain.execute(requestContext)
        }
    }
    
    func doPlay(track: Track, params: PlaybackParams) {
        
        guard let audioFormat = track.playbackContext?.audioFormat else {
            
            NSLog("Player.play() - Unable to play track \(track.displayName) because no audio format is set in its playback context.")
            return
        }
        
        // Disconnect player from audio graph and reconnect with the file's processing format
        audioGraph.reconnectPlayerNode(withFormat: audioFormat)
        
        let session = PlaybackSession.start(track)
        self.scheduler = track.isNativelySupported ? avfScheduler : ffmpegScheduler
        
        if let end = params.endPosition {
            
            // Segment loop is defined
            PlaybackSession.defineLoop(params.startPosition ?? 0, end)
            scheduler.playLoop(session, beginPlayback: true)
            
        } else {
            
            // No segment loop
            scheduler.playTrack(session, from: params.startPosition)
        }
        
        state = .playing
    }
    
    func pause() {
        
        scheduler.pause()
        audioGraph.clearSoundTails()
        
        state = .paused
    }
    
    func resume() {
        
        scheduler.resume()
        state = .playing
    }
    
    func resumeIfPaused() {
        
        if state == .paused {
            resume()
        }
    }
    
    func replay() {
        
        if state.isPlayingOrPaused {
            
            forceSeek(to: 0)
            resumeIfPaused()
        }
    }
    
    func stop() {
        initiateStop()
    }
    
    // theCurrentTrack points to the (precomputed) current track before this stop operation.
    // It is required because sometimes, the sequence will have been cleared before stop() is called,
    // making it impossible to capture the current track before stopping playback.
    // If nil, the current track can be computed normally (by calling playingTrack).
    func initiateStop(_ theCurrentTrack: Track? = nil) {
        
        let stateBeforeChange = state
        
        if stateBeforeChange != .stopped {
            
            let trackBeforeChange = theCurrentTrack ?? playingTrack
            let seekPositionBeforeChange = seekPosition.timeElapsed
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil, PlaybackParams.defaultParams())
            stopPlaybackChain.execute(requestContext)
        }
    }
    
    func doStop() {
        
        PlaybackSession.endCurrent()
        
        scheduler?.stop()
        playerNode.reset()
        audioGraph.clearSoundTails()
        
        state = .stopped
    }
    
    // Continues playback when a track finishes playing.
    func trackPlaybackCompleted() {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        
        // NOTE - Seek position should always be 0 here because the track finished playing.
        let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, 0, nil, PlaybackParams.defaultParams())
        
        trackPlaybackCompletedChain.execute(requestContext)
    }
    
    // MARK: Gapless ------------------------------------------------------
    
    func beginGaplessPlayback() throws {
        
        try playQueue.prepareForGaplessPlayback()
//        doBeginGaplessPlayback()
    }
    
    var isInGaplessPlaybackMode: Bool {
        false
    }
}
