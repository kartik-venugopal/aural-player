//
// DiscretePlayer+Looping.swift
// Aural
//
// Copyright © 2025 Kartik Venugopal. All rights reserved.
//
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    func defineLoop(startPosition: TimeInterval, endPosition: TimeInterval, isChapterLoop: Bool) {
        
        if let currentSession = PlaybackSession.startNewSessionForPlayingTrack() {
            
            PlaybackSession.defineLoop(startPosition, endPosition, isChapterLoop)
            scheduler.playLoop(currentSession, from: playerPosition, beginPlayback: isPlaying)
        }
    }
    
    @discardableResult func toggleLoop() -> PlaybackLoop? {
        
        // Capture the current seek position
        let currentSeekPos = playerPosition
        
        // Make sure that there is a track currently playing.
        if PlaybackSession.hasCurrentSession() {
            
            if PlaybackSession.hasLoop() {
                
                // If loop is complete, remove it, otherwise mark its end time.
                PlaybackSession.hasCompleteLoop() ? removeLoop() : endLoop(currentSeekPos)
                
            } else {
                
                // No loop currently defined, mark its start time.
                beginLoop(currentSeekPos)
            }
        }
        
        return playbackLoop
    }
    
    private func beginLoop(_ seekPos: TimeInterval) {
        
        // Loop is currently undefined, mark its start time. No changes in playback ... playback continues as before.
        PlaybackSession.beginLoop(seekPos)
    }
    
    private func endLoop(_ seekPos: TimeInterval) {
        
        // Loop has a start time, but no end time ... mark its end time
        PlaybackSession.endLoop(seekPos)
        
        // When the loop's end time is defined, playback jumps back to the loop's start time, and a new playback session is started.
        if let newSession = PlaybackSession.startNewSessionForPlayingTrack() {
            scheduler.playLoop(newSession, beginPlayback: isPlaying)
        }
    }
    
    private func removeLoop() {
        
        // Note this down before removing the loop
        if let loopEndTime = playbackLoop?.endTime {
            
            // Loop has an end time (i.e. is complete) ... remove loop
            PlaybackSession.removeLoop()
            
            // When a loop is removed, playback continues from the current position and a new playback session is started.
            if let newSession = PlaybackSession.startNewSessionForPlayingTrack() {
                scheduler.endLoop(newSession, loopEndTime, isPlaying)
            }
        }
    }
    
    var playbackLoop: PlaybackLoop? {
        PlaybackSession.currentLoop
    }
    
    var playbackLoopState: PlaybackLoopState {
        
        if let loop = playbackLoop {
            return loop.isComplete ? .complete : .started
        }
        
        return .none
    }
}
