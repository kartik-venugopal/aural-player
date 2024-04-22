//
//  SeekTimeFormats.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

///
/// Enumeration of all possible formats in which the current track time / position is displayed.
///
import Foundation

enum TrackTimeDisplayType: String, CaseIterable, Codable {
    
    case elapsed
    case remaining
    case duration
}
