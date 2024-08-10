//
//  Player+Looping.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Player {
    
    func defineLoop(_ loopStartPosition: Double, _ loopEndPosition: Double, _ isChapterLoop: Bool = false) {
        
        if let currentSession = PlaybackSession.startNewSessionForPlayingTrack() {

            PlaybackSession.defineLoop(loopStartPosition, loopEndPosition, isChapterLoop)
            scheduler.playLoop(currentSession, seekPosition, state == .playing)
        }
    }
    
    func toggleLoop() -> PlaybackLoop? {
        
        // Capture the current seek position
        let currentSeekPos = seekPosition

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
    
    private func beginLoop(_ seekPos: Double) {
        
        // Loop is currently undefined, mark its start time. No changes in playback ... playback continues as before.
        PlaybackSession.beginLoop(seekPos)
    }
    
    private func endLoop(_ seekPos: Double) {
        
        // Loop has a start time, but no end time ... mark its end time
        PlaybackSession.endLoop(seekPos)
        
        // When the loop's end time is defined, playback jumps back to the loop's start time, and a new playback session is started.
        if let newSession = PlaybackSession.startNewSessionForPlayingTrack() {
            scheduler.playLoop(newSession, state == .playing)
        }
    }
    
    private func removeLoop() {
        
        // Note this down before removing the loop
        if let loopEndTime = playbackLoop?.endTime {
            
            // Loop has an end time (i.e. is complete) ... remove loop
            PlaybackSession.removeLoop()
            
            // When a loop is removed, playback continues from the current position and a new playback session is started.
            if let newSession = PlaybackSession.startNewSessionForPlayingTrack() {
                scheduler.endLoop(newSession, loopEndTime, state == .playing)
            }
        }
    }
    
    var playbackLoop: PlaybackLoop? {
        PlaybackSession.currentLoop
    }
}
