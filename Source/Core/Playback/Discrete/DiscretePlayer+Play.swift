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
        doPlay(playQueue.start)
    }
    
    func play(trackAtIndex index: Int, params: PlaybackParams) {
        
        doPlay({
            playQueue.select(trackAt: index)
        }, params)
    }
    
    func play(track: Track, params: PlaybackParams) {
        
        doPlay({
            playQueue.selectTrack(track)
        }, params)
    }
    
    func previousTrack() {
        
        if state.isPlayingOrPaused {
            doPlay(playQueue.previous)
        }
    }
    
    func nextTrack() {
        
        if state.isPlayingOrPaused {
            doPlay(playQueue.next)
        }
    }
    
    func resumeShuffleSequence(with track: Track, atPosition position: TimeInterval) {
        
        doPlay({
            playQueue.resumeShuffleSequence(with: track)
        }, .init().withStartAndEndPosition(position))
    }
    
    // Captures the current player state and proceeds with playback according to the playback sequence
    private func doPlay(_ trackProducer: TrackProducer, _ params: PlaybackParams = .defaultParams()) {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = playerPosition
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
        
        if okToPlay, let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, params)
            startPlaybackChain.execute(requestContext)
        }
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
        
        _ = PlaybackSession.endCurrent()
        
        scheduler?.stop()
        playerNode.reset()
        audioGraph.clearSoundTails()
        
        state = .stopped
    }
    
    // Continues playback when a track finishes playing.
    func doTrackPlaybackCompleted() {
        
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
