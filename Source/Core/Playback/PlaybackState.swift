//
//  PlaybackState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all possible playback states of the Player.
///
enum PlaybackState: String, CaseIterable {
    
    case playing
    case paused
    case stopped
    
    var isPlayingOrPaused: Bool {
        self != .stopped
    }
    
    var isStopped: Bool {
        self == .stopped
    }
}
