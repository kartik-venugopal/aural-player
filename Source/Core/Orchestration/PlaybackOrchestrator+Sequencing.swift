//
// PlaybackOrchestrator+Sequencing.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlaybackOrchestrator {
    
    var repeatMode: RepeatMode {
        playQueue.repeatMode
    }
    
    func toggleRepeatMode() {
        
        let modes = playQueue.toggleRepeatMode()
        ui?.repeatAndShuffleModesChanged(newRepeatMode: modes.repeatMode, newShuffleMode: modes.shuffleMode)
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) {
        
        let modes = playQueue.setRepeatMode(repeatMode)
        ui?.repeatAndShuffleModesChanged(newRepeatMode: modes.repeatMode, newShuffleMode: modes.shuffleMode)
    }
    
    var shuffleMode: ShuffleMode {
        playQueue.shuffleMode
    }
    
    func toggleShuffleMode() {
        
        let modes = playQueue.toggleShuffleMode()
        ui?.repeatAndShuffleModesChanged(newRepeatMode: modes.repeatMode, newShuffleMode: modes.shuffleMode)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) {
        
        let modes = playQueue.setShuffleMode(shuffleMode)
        ui?.repeatAndShuffleModesChanged(newRepeatMode: modes.repeatMode, newShuffleMode: modes.shuffleMode)
    }
}
