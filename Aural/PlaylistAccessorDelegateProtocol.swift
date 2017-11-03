import Foundation

/*
    Contract for a middleman/delegate that relays read-only operations to the playlist
 */
protocol PlaylistAccessorDelegateProtocol {
    
    // Retrieve all tracks
    func allTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func trackAtIndex(_ index: Int?) -> IndexedTrack?
    
    func groupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
    
    // Returns a summary of the playlist - both size and total duration
    func summary() -> (size: Int, totalDuration: Double)
    
    // Returns a summary of the playlist - both size and total duration
    func summary(_ groupType: GroupType) -> (size: Int, totalDuration: Double, numGroups: Int)
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery, _ groupType: GroupType) -> SearchResults
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group
    
    func numberOfGroups(_ type: GroupType) -> Int
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack
    
    func indexOfGroup(_ group: Group) -> Int
    
    func displayNameForTrack(_ type: GroupType, _ track: Track) -> String
}
