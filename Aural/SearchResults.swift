import Cocoa

/*
    Encapsulates the results of a playlist search, and provides convenient functions for iteration
 */
class SearchResults {
    
    // Total number of results
    var count: Int
    
    var results: [SearchResult]
    
    // Marks the current result (used during iteration)
    private var cursor: Int = -1
    
    init(_ results: [SearchResult]) {
        
        self.results = results
        count = results.count
        
        if (count > 0) {
        
            for i in 0...count - 1 {
                
                results[i].resultIndex = i + 1
                results[i].hasPrevious = i > 0
                results[i].hasNext = i < count - 1
            }
        }
    }
    
    // Retrieve the next result, if there is one
    func next() -> SearchResult? {
        
        if (count == 0 || cursor >= (count - 1)) {
            return nil
        }
        
        cursor += 1
        return results[cursor]
    }
    
    // Retrieve the previous result, if there is one
    func previous() -> SearchResult? {
        
        if (count == 0 || cursor < 1) {
            return nil
        }
        
        cursor -= 1
        return results[cursor]
    }
    
    // Perform a union of this set of results with another set
    func union(_ otherResults: SearchResults) -> SearchResults {
        
        var union = Set<SearchResult>()
        
        // Add results from the two sets into the union set (duplicates will be removed automatically by the union set)
        self.results.forEach({union.insert($0)})
        otherResults.results.forEach({union.insert($0)})
        
        return SearchResults(Array(union))
    }
    
    // For display in tracks view
    func sortedByTrackIndex() -> SearchResults {
        
        // Sorts in ascending order by track index
        results.sort(by: {r1, r2 -> Bool in
            return r1.location.trackIndex! < r2.location.trackIndex!
        })
        
        return SearchResults(results)
    }
    
    // For display in grouping/hierarchical views
    func sortedByGroupAndTrackIndex() -> SearchResults {
        
        // Sorts in ascending order by group index (and track index if group indexes are equal)
        results.sort(by: {r1, r2 -> Bool in
            
            let g1 = r1.location.groupInfo!.groupIndex
            let g2 = r2.location.groupInfo!.groupIndex
            
            if (g1 == g2) {
                return r1.location.groupInfo!.trackIndex < r2.location.groupInfo!.trackIndex
            }
            
            return g1 < g2
        })
        
        // TODO: Can I return self ?
        return SearchResults(results)
    }
}

// Represents a single result (track) in a playlist search
class SearchResult: Hashable  {
    
    // The index of this result within the set of all results
    var resultIndex: Int
    
    // The location of the track represented by this result, within the playlist
    var location: SearchResultLocation
    
    // Describes which field matched the search query, and its value
    var match: (fieldKey: String, fieldValue: String)
    
    // Flag to indicate whether there is another result to consume after this one (during iteration)
    var hasNext: Bool = false
    
    // Flag to indicate whether there is another result to consume before this one (during iteration)
    var hasPrevious: Bool = false
    
    // Needed for Hashable conformance
    /**public var hashValue: Int {
        
        // The file path of the track is the unique identifier
        return location.track.file.path.hashValue
    }**/
    
    func hash(into hasher: inout Hasher) {
        // The file path of the track is the unique identifier
        return hasher.combine(location.track.file.path)
        
    }
    
    
    
    init(location: SearchResultLocation, match: (fieldKey: String, fieldValue: String)) {
        
        // This field will be set by SearchResults
        self.resultIndex = -1
        
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
