import Foundation

/*
    Contract for read-only playlist operations
 */
protocol PlaylistAccessorProtocol {
    
    // Retrieve all tracks
    func getTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track?) -> Int?
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
    
    // Returns a summary of the playlist - both size and total duration
    func summary() -> (size: Int, totalDuration: Double)
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
}

/*
    Contract for mutating/write playlist operations
 */
protocol PlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist. If the track was not added, the returned value will be -1.
    func addTrack(_ track: Track) -> Int
    
    // Removes tracks with the given indexes
    func removeTracks(_ indexes: [Int])
    
    // Clears the entire playlist of all tracks
    func clear()
    
    /*
        Moves the tracks at the specified indexes, up one index, in the playlist, if they can be moved (they are not already at the top). Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksUp(_ indexes: IndexSet) -> [Int: Int]
    
    /*
        Moves the tracks at the specified indexes, down one index, in the playlist, if they can be moved (they are not already at the bottom). Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksDown(_ indexes: IndexSet) -> [Int: Int]
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
    
    // Performs a sequence of playlist reorder operations
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation])
}

/*
    Contract for all read-only and mutating/write playlist operations
 */
protocol PlaylistCRUDProtocol: PlaylistAccessorProtocol, PlaylistMutatorProtocol {
}
