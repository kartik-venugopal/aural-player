//
//  PlaybackPositionDisplayType.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

///
/// Enumeration of all possible formats in which the current playback position is displayed.
///
import Foundation

enum PlaybackPositionDisplayType: String, CaseIterable, Codable {
    
    case elapsed
    case remaining
    case duration
}
