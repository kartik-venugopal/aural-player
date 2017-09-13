/*
    Encapsulates the results of a search for tracks performed on the playlist, and provides convenient functions for iteration
 */

import Cocoa

class SearchResults {
    
    // Total number of results
    var count: Int
    
    private var results: [SearchResult]
    
    // Marks the current result (used during iteration)
    private var cursor: Int = -1
    
    init(results: [SearchResult]) {
        self.results = results
        count = results.count
        
        if (count > 0) {
        
            for i in 0...count - 1 {
                
                if (i > 0) {
                    results[i].hasPrevious = true
                }
                
                if (i < count - 1) {
                    results[i].hasNext = true
                }
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
}

// Represents a single result (track) in a playlist tracks search
class SearchResult {
    
    // The index of this result within the set of all results
    var resultIndex: Int
    
    // The index of the track represented by this result, within the playlist
    var trackIndex: Int
    
    // Describes which field matched the search query, and its value
    var match: (fieldKey: String, fieldValue: String)
    
    // Flag to indicate whether there is another result to consume after this one (during iteration)
    var hasNext: Bool = false
    
    // Flag to indicate whether there is another result to consume before this one (during iteration)
    var hasPrevious: Bool = false
    
    init(resultIndex: Int, trackIndex: Int, match: (fieldKey: String, fieldValue: String)) {
        
        self.resultIndex = resultIndex
        self.trackIndex = trackIndex
        self.match = match
    }
}
