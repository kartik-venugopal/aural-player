//
//  SearchResultLocation.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// Encapsulates information used to locate a single search result within a playlist view.
///
class SearchResultLocation: Equatable {
    
    let scope: SearchScope
    
    // The track whose location is being described.
    var track: Track
    
    var description: String {
        ""
    }
    
    fileprivate init(scope: SearchScope, track: Track) {
        self.scope = scope
        self.track = track
    }
    
    static func == (lhs: SearchResultLocation, rhs: SearchResultLocation) -> Bool {
        lhs.scope == rhs.scope && lhs.track == rhs.track
    }
    
//    // Only for flat playlists.
//    var trackIndex: Int?
//    
//    // Only for grouping playlists.
//    var groupInfo: GroupedTrack?
//    
//    // Two locations are equal if they describe the location of the same track
//    public static func ==(lhs: SearchResultLocation, rhs: SearchResultLocation) -> Bool {
//        return lhs.track == rhs.track
//    }
}

class PlayQueueSearchResultLocation: SearchResultLocation {
    
    let index: Int
    
    init(scope: SearchScope, track: Track, index: Int) {
        
        self.index = index
        super.init(scope: scope, track: track)
    }
    
    override var description: String {
        "Play Queue: #\(index + 1)"
    }
}
