//
//  PlayerViewController+Actions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension PlayerViewController {
    
    @IBAction func togglePlayPauseAction(_ sender: NSButton) {

        let result = playbackOrch.togglePlayPause()
        btnPlayPauseStateMachine.setState(result.state)
        
    }
    
    @IBAction func previousTrackAction(_ sender: NSButton) {
        playbackOrch.previousTrack()
    }
    
    @IBAction func nextTrackAction(_ sender: NSButton) {
        playbackOrch.nextTrack()
    }
    
    @IBAction func seekSliderAction(_ sender: NSSlider) {
        playbackOrch.seekTo(percentage: seekSlider.doubleValue)
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: NSButton) {
        playbackOrch.seekBackward()
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: NSButton) {
//        seekForward(inputMode: .discrete)
        playbackOrch.seekForward()
    }
    
    @IBAction func toggleLoopAction(_ sender: NSButton) {
        playbackOrch.toggleLoop()
    }
    
    @IBAction func togglePlaybackPositionDisplayTypeAction(_ sender: NSTextField) {
        
        playerUIState.playbackPositionDisplayType = playerUIState.playbackPositionDisplayType.toggleCase()
        setPlaybackPositionDisplayType(to: playerUIState.playbackPositionDisplayType)
    }
    
    @IBAction func volumeAction(_ sender: NSSlider) {
        
        audioGraph.scaledVolume = volumeSlider.floatValue
        volumeChanged(volume: audioGraph.scaledVolume, muted: audioGraph.muted, updateSlider: false)
    }
    
    @IBAction func muteOrUnmuteAction(_ sender: NSButton) {
        muteOrUnmute()
    }
    
    @IBAction func toggleRepeatModeAction(_ sender: NSButton) {
        playbackOrch.toggleRepeatMode()
    }
    
    @IBAction func toggleShuffleModeAction(_ sender: NSButton) {
        
//        guard !player.isInGaplessPlaybackMode else {
//            
//            NSAlert.showInfo(withTitle: "Function unavailable", andText: "Shuffling is not possible while in gapless playback mode.")
//            return
//        }
        
        playbackOrch.toggleShuffleMode()
    }
}

extension AudioGraphProtocol {
    
    var scaledVolume: Float {
        
        get {round(volume * ValueConversions.volume_audioGraphToUI)}
        set {volume = newValue * ValueConversions.volume_UIToAudioGraph}
    }
}
