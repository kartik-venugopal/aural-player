//
//  RepeatAndShuffleModes.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An enumeration of all possible playback repeat modes.
///
enum RepeatMode: String, CaseIterable {
    
    static let defaultMode: RepeatMode = .off
    
    // Play all tracks once, in sequence order
    case off
    
    // Repeat one track forever
    case one
    
    // Repeat all tracks forever, in sequence order
    case all
    
    // Returns a RepeatMode that is the result of toggling this RepeatMode.
    func toggled() -> RepeatMode {
        
        switch self {
            
        case .off:
            
            return .one
            
        case .one:
            
            return .all
            
        case .all:
            
            return .off
        }
    }
}

///
/// An enumeration of all possible playback shuffle modes.
///
enum ShuffleMode: String, CaseIterable {
    
    static let defaultMode: ShuffleMode = .off
    
    // Play tracks in random order
    case on
    
    // Don't shuffle
    case off
    
    // Returns a ShuffleMode that is the result of toggling this ShuffleMode.
    func toggled() -> ShuffleMode {
        return self == .on ? .off : .on
    }
}
