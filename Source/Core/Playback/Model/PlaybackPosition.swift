//
// PlaybackPosition.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

///
/// Encapsulates information about the playback position of the currently playing track.
///
struct PlaybackPosition {
    
    let timeElapsed: TimeInterval
    let percentageElapsed: Double
    let trackDuration: TimeInterval
    
    static let zero: PlaybackPosition = PlaybackPosition(timeElapsed: 0, percentageElapsed: 0, trackDuration: 0)
}
