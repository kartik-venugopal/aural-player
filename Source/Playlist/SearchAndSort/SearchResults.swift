//
//  SearchResults.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Encapsulates the results of a playlist search, and provides convenient functions for iteration
 */
class SearchResults {
    
    // Total number of results
    var count: Int {results.count}
    
    var hasResults: Bool {results.count > 0}
    
    private(set) var results: [SearchResult]
    
    // Marks the current result (used during iteration)
    private var cursor: Int = -1
    
    init(_ results: [SearchResult]) {
        self.results = results
    }
    
    var currentIndex: Int {cursor}
    
    // Retrieve the next result, if there is one
    func next() -> SearchResult? {
        return count == 0 || cursor >= (count - 1) ? nil : results[cursor.incrementAndGet()]
    }
    
    var hasNext: Bool {
        return count > 0 && cursor < count - 1
    }
    
    // Retrieve the previous result, if there is one
    func previous() -> SearchResult? {
        return count == 0 || cursor < 1 ? nil : results[cursor.decrementAndGet()]
    }
    
    var hasPrevious: Bool {
        return count > 0 && cursor > 0
    }
    
    // Perform a union of this set of results with another set
    func performUnionWith(_ otherResults: SearchResults) {
        
        var union = Set<SearchResult>()
        
        // Add results from the two sets into the union set (duplicates will be removed automatically by the union set)
        self.results.forEach({union.insert($0)})
        otherResults.results.forEach({union.insert($0)})
        
        self.results = Array(union)
    }
    
    // Sorts in ascending order by track index
    // For display in tracks view
    func sortByTrackIndex() {
        results.sort(by: {$0.location.trackIndex! < $1.location.trackIndex!})
    }

    // Sorts in ascending order by group index (and track index if group indexes are equal)
    // For display in grouping/hierarchical views
    func sortByGroupAndTrackIndex() {
        
        results.sort(by: {r1, r2 -> Bool in
            
            let g1 = r1.location.groupInfo!.groupIndex
            let g2 = r2.location.groupInfo!.groupIndex
            
            return g1 == g2 ? r1.location.groupInfo!.trackIndex < r2.location.groupInfo!.trackIndex : g1 < g2
        })
    }
}

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

// Encapsulates information used to locate a single search result within a playlist
struct SearchResultLocation: Equatable {
    
    // Only for flat playlists
    var trackIndex: Int?
    
    // The track whose location is being described
    let track: Track
    
    // Only for grouping playlists
    var groupInfo: GroupedTrack?
    
    // Two locations are equal if they describe the location of the same track
    public static func ==(lhs: SearchResultLocation, rhs: SearchResultLocation) -> Bool {
        return lhs.track === rhs.track
    }
}
