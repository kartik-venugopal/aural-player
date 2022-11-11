//
//  RepeatAndShuffleModes.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
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
