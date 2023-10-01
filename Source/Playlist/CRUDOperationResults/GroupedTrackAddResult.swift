//
//  GroupedTrackAddResult.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the result of adding a track to a single grouping playlist.
///
struct GroupedTrackAddResult {
    
    // Grouping info for the added track
    let track: GroupedTrack
    
    // Whether or not the parent group of the added track was created as a result of adding the track (i.e. the added track is the only child of the parent group)
    let groupCreated: Bool
}
