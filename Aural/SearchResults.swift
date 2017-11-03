/*
    Encapsulates the results of a playlist search, and provides convenient functions for iteration
 */

import Cocoa

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
    
    func union(_ otherResults: SearchResults) -> SearchResults {
        
        var union = Set<SearchResult>()
        
        self.results.forEach({union.insert($0)})
        otherResults.results.forEach({union.insert($0)})
        
        return SearchResults(Array(union))
    }
    
    // For display in tracks view
    func sortedByTrackIndex() -> SearchResults {
        
        results.sort(by: {r1, r2 -> Bool in
            
            let i1 = r1.location.trackIndex!
            let i2 = r2.location.trackIndex!
            
            return i1 < i2
        })
        
        return SearchResults(results)
    }
    
    // For display in grouping views
    func sortedByGroupAndTrackIndex() -> SearchResults {
        
        results.sort(by: {r1, r2 -> Bool in
            
            let g1 = r1.location.groupInfo!.groupIndex
            let g2 = r2.location.groupInfo!.groupIndex
            
            if (g1 == g2) {
                
                let t1 = r1.location.groupInfo!.trackIndex
                let t2 = r2.location.groupInfo!.trackIndex
                
                return t1 < t2
            }
            
            return g1 < g2
        })
        
        // TODO: Can I return self ?
        return SearchResults(results)
    }
}

// Represents a single result (track) in a playlist tracks search
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
    
    public var hashValue: Int {
        return location.track.file.path.hashValue
    }
    
    init(location: SearchResultLocation, match: (fieldKey: String, fieldValue: String)) {
        
        // This field will be set by SearchResults
        self.resultIndex = -1
        
        self.location = location
        self.match = match
    }
    
    public static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.location == rhs.location
    }
}

struct SearchResultLocation: Equatable {
    
    // Only for flat playlists
    var trackIndex: Int?
    
    let track: Track
    
    // Only for grouping playlists
    var groupInfo: GroupedTrack?
    
    public static func ==(lhs: SearchResultLocation, rhs: SearchResultLocation) -> Bool {
        return lhs.track === rhs.track
    }
}
