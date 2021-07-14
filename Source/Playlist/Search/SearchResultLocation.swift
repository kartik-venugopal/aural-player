//
//  SearchResultLocation.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// Encapsulates information used to locate a single search result within a playlist view.
///
struct SearchResultLocation: Equatable {
    
    // The track whose location is being described.
    let track: Track
    
    // Only for flat playlists.
    var trackIndex: Int?
    
    // Only for grouping playlists.
    var groupInfo: GroupedTrack?
    
    // Two locations are equal if they describe the location of the same track
    public static func ==(lhs: SearchResultLocation, rhs: SearchResultLocation) -> Bool {
        return lhs.track == rhs.track
    }
}
