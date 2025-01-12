//
//  ShuffleMode.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all possible playback shuffle modes.
///
enum ShuffleMode: String, CaseIterable, Codable {
    
    static let defaultMode: ShuffleMode = .off
    
    // Don't shuffle
    case off
    
    // Play tracks in random order
    case on
}
