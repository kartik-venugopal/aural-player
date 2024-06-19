//
//  PlayerSeekResult.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An immutable value object that encapsulate the result of a Player seek operation.
///
struct PlayerSeekResult {
    
    // The potentially adjusted seek position (eg. if attempted seek time was < 0, it will be adjusted to 0).
    // This is the seek position actually used in the seek operation.
    // If no adjustment took place, this will be equal to the attempted seek position.
    let actualSeekPosition: Double
    
    // Whether or not a previously defined segment loop was removed as a result of the seek.
    let loopRemoved: Bool
    
    // Whether or not the seek resulted in track playback completion (i.e. reached the end of the track).
    let trackPlaybackCompleted: Bool
}
