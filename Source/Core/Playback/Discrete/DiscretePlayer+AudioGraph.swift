//
// DiscretePlayer+AudioGraph.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    // When the audio output device changes, restart the audio engine and continue playback as before.
    func audioOutputDeviceChanged() {
        
        // First, check if a track is playing.
        guard let curSession = PlaybackSession.startNewSessionForPlayingTrack() else {return}
        
        // Mark the current seek position
        let curSeekPos = playerPosition
        
        // Resume playback from the same seek position
        scheduler.seekToTime(curSession, curSeekPos, isPlaying)
    }
    
    func preAudioGraphChange(_ notif: PreAudioGraphChangeNotification) {
        
        guard let currentSession = PlaybackSession.startNewSessionForPlayingTrack() else {return}
        
        notif.context.playbackSession = currentSession
        notif.context.isPlaying = isPlaying
        
        notif.context.seekPosition = playerPosition
        cachedSeekPosition = notif.context.seekPosition
        
        PlaybackSession.endCurrent()
        scheduler?.stop()
    }
    
    // When the audio output device changes, restart the audio engine and continue playback as before.
    func audioGraphChanged(_ notif: AudioGraphChangedNotification) {
        
        // First, check if a track is playing.
        guard let endedSession = notif.context.playbackSession,
              let seekPosition = notif.context.seekPosition else {return}
        
        let newSession = PlaybackSession.duplicateSessionAndMakeCurrent(endedSession)
        
        // Resume playback from the same seek position
        scheduler.seekToTime(newSession, seekPosition, notif.context.isPlaying)
        cachedSeekPosition = nil
    }
    
    func tearDown() {
        stop()
    }
}
