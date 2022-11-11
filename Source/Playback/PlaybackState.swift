//
//  PlaybackState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all possible playback states of the Player.
///
enum PlaybackState {
    
    case playing
    case paused
    case noTrack
    
    var isPlayingOrPaused: Bool {
        self.equalsOneOf(.playing, .paused)
    }
    
    var isNotPlayingOrPaused: Bool {
        !isPlayingOrPaused
    }
}
