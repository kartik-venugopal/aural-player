//
// PlayerViewController+PlaybackUI.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlayerViewController: PlaybackUI {
    
    var id: String {
        className
    }
    
    func playbackStateChanged(newState: PlaybackState) {
        
        btnPlayPauseStateMachine.setState(newState)
        setSeekTimerState(to: newState == .playing)
    }
    
    func playingTrackChanged(newTrack: Track?) {
        trackChanged(to: newTrack)
    }
    
    func playbackPositionChanged(newPosition: PlaybackPosition?) {
        updateSeekPosition(to: newPosition ?? .zero)
    }
}
