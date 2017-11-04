import Foundation

protocol FlatPlaylistAccessorProtocol {
    
    // Retrieve all tracks
    func allTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func trackAtIndex(_ index: Int?) -> IndexedTrack?
 
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track) -> Int?
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
}

protocol FlatPlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist.
    func addTrack(_ track: Track) -> Int?
    
    // Removes tracks with the given indexes
    func removeTracks(_ indexes: IndexSet) -> [Track]
    
    func removeTracks(_ tracks: [Track]) -> IndexSet
    
    /*
     Moves the tracks at the specified indexes, up one index, in the playlist, if they can be moved (they are not already at the top). Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
     NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
     Moves the tracks at the specified indexes, down one index, in the playlist, if they can be moved (they are not already at the bottom). Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
     NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}

protocol FlatPlaylistCRUDProtocol: FlatPlaylistAccessorProtocol, FlatPlaylistMutatorProtocol {}
