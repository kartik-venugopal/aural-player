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
    
    func playbackLoopChanged(newLoop: PlaybackLoop?, newLoopState: PlaybackLoopState) {
        
        btnLoopStateMachine.setState(newLoopState)

        // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
        
        if let playingTrack = playbackOrch.playingTrack, let loop = newLoop {
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            let trackDuration = playingTrack.duration
            let startPerc = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(startPerc: startPerc)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                let endPerc = (loopEndTime / trackDuration) * 100
                seekSliderCell.markLoopEnd(endPerc: endPerc)
            }
            
        } else {
            seekSliderCell.removeLoop()
        }

        seekSlider.redraw()
        updateSeekPosition()
    }
    
    func repeatAndShuffleModesChanged(newRepeatMode: RepeatMode, newShuffleMode: ShuffleMode) {
        
        btnRepeatStateMachine.setState(newRepeatMode)
        btnShuffleStateMachine.setState(newShuffleMode)
    }
}
