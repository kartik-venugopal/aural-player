//
//  RepeatAndShuffleModes.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An enumeration of all possible playback repeat modes.
///
enum RepeatMode: String, CaseIterable, Codable {
    
    static let defaultMode: RepeatMode = .off
    
    // Play all tracks once, in sequence order
    case off
    
    // Repeat all tracks forever, in sequence order
    case all
    
    // Repeat one track forever
    case one
}
