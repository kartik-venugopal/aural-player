//
//  TrackInfoSource.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

typealias KeyValuePair = (key: String, value: String)

struct TrackInfoConstants {
    
    static let value_unknown: String = "<Unknown>"
}

protocol TrackInfoSource {
    
    func loadTrackInfo(for track: Track)
    
    var trackInfo: [KeyValuePair] {get}
}
