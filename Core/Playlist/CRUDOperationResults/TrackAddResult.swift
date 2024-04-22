//
//  TrackAddResult.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the aggregated results of adding a single track to each of the playlist types.
///
struct TrackAddResults {
    
    // Index of the added track, within the flat playlist
    let indices: IndexSet
    
    // Grouping info for the added track, within each of the grouping playlists
    let groupingResults: [Grouping: [GroupedTrackAddResult]]
}
