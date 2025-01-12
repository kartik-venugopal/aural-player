//
//  SearchResult.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// Represents a single result (track) of a playlist search.
///
class SearchResult: Hashable  {
    
    init(location: SearchResultLocation, match: SearchResultMatch) {
        
        self.location = location
        self.match = match
    }
    
    // The location of the track represented by this result, within the playlist.
    var location: SearchResultLocation
    
    // Describes which field matched the search query, and its value.
    let match: SearchResultMatch
    
    // Needed for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(location.track.file)
    }
    
    // Two SearchResult objects are equal if their locations are equal (i.e. they point to the same track)
    public static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.location == rhs.location
    }
}
