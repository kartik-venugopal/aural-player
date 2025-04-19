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
//        doPlay({playQueueDelegate.start()}, PlaybackParams.defaultParams())
    }
    
    func play(trackAtIndex index: Int, params: PlaybackParams) {
        
    }
    
    func play(track: Track, params: PlaybackParams) {
        
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
    
    func replay() {
        
    }
    
    func stop() {
        
        _ = PlaybackSession.endCurrent()
        
        scheduler?.stop()
        playerNode.reset()
        audioGraph.clearSoundTails()
        
        state = .stopped
    }
}
