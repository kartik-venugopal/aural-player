import Foundation

/*
    Contract for a middleman/delegate that relays read-only operations to the playlist
 */
protocol PlaylistAccessorDelegateProtocol {
    
    // Retrieve all tracks
    func getTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
    
    // Returns a summary of the playlist - both size and total duration
    func summary() -> (size: Int, totalDuration: Double)
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
}
