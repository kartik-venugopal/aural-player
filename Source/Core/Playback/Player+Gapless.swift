//
//  Player+Gapless.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Player: GaplessPlaybackProtocol {
    
    func playGapless(tracks: [Track]) {
        
        guard let track = tracks.first, let audioFormat = track.playbackContext?.audioFormat else {
            
            NSLog("Player.play() - Unable to play gapless because no audio format is set in its playback context.")
            return
        }
        
        isInGaplessPlaybackMode = true
        
        // Disconnect player from audio graph and reconnect with the file's processing format
        graph.reconnectPlayerNode(withFormat: audioFormat)

        let session = PlaybackSession.start(track)
        self.scheduler = track.isNativelySupported ? avfScheduler : ffmpegScheduler
        scheduler.playGapless(tracks: tracks, currentSession: session)

        state = .playing
    }
}
