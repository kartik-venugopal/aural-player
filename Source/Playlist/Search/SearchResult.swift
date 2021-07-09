//
//  SearchResult.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

// Represents a single result (track) in a playlist search
class SearchResult: Hashable  {
    
    // The location of the track represented by this result, within the playlist
    var location: SearchResultLocation
    
    // Describes which field matched the search query, and its value
    var match: (fieldKey: String, fieldValue: String)
    
    // Needed for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(location.track.file.path)
    }
    
    init(location: SearchResultLocation, match: (fieldKey: String, fieldValue: String)) {
        
        self.location = location
        self.match = match
    }
    
    // Two SearchResult objects are equal if their locations are equal (i.e. they point to the same track)
    public static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.location == rhs.location
    }
}
