//
// DiscretePlayer+Seek.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    func seekForward(by interval: TimeInterval) {
        
    }
    
    func seekBackward(by interval: TimeInterval) {
        
    }
    
    func seekToPercentage(_ percentage: Double) {
        
    }
    
    func seekToTime(_ seconds: TimeInterval) {
        
    }
    
    func attemptSeekToTime(_ seconds: TimeInterval) -> PlayerSeekResult {
        .init(actualSeekPosition: 0, loopRemoved: false, trackPlaybackCompleted: false)
    }
    
    func forceSeekToTime(_ seconds: TimeInterval) -> PlayerSeekResult {
        .init(actualSeekPosition: 0, loopRemoved: false, trackPlaybackCompleted: false)
    }
}
