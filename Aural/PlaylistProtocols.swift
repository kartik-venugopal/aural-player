import Foundation

/*
    Contract for read-only playlist operations
 */
protocol PlaylistAccessorProtocol: CommonPlaylistAccessorProtocol, FlatPlaylistAccessorProtocol, GroupingPlaylistSelectiveAccessorProtocol {
    
    // Retrieve all tracks
    func getTracks() -> [Track]
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
    
    // Returns a summary of the playlist - both size and total duration
    func summary() -> (size: Int, totalDuration: Double)
}

/*
    Contract for mutating/write playlist operations
 */
protocol PlaylistMutatorProtocol: CommonPlaylistMutatorProtocol, FlatPlaylistMutatorProtocol, GroupingPlaylistSelectiveMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist. If the track was not added, the returned value will be -1.
    func addTrack(_ track: Track) -> TrackAddResult?
}

/*
    Contract for all read-only and mutating/write playlist operations
 */
protocol PlaylistCRUDProtocol: PlaylistAccessorProtocol, PlaylistMutatorProtocol {
}

protocol CommonPlaylistAccessorProtocol {
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
}

protocol CommonPlaylistMutatorProtocol {
    
    // Clears the entire playlist of all tracks
    func clear()
    
    func removeTracks(_ tracks: [Track])
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}
