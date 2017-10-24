import Foundation

protocol FlatPlaylistAccessorProtocol: CommonPlaylistAccessorProtocol {
    
    // Retrieve all tracks
    func getTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
 
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track) -> Int?
}

protocol FlatPlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist.
    func addTrackForIndex(_ track: Track) -> Int?
    
    // TODO: Use IndexSet for argument
    // Removes tracks with the given indexes
    func removeTracks(_ indexes: IndexSet) -> [Track]
    
    func removeTracks(_ tracks: [Track]) -> IndexSet
    
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
    
    // Performs a sequence of playlist reorder operations
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation])
}

protocol FlatPlaylistCRUDProtocol: FlatPlaylistAccessorProtocol, FlatPlaylistMutatorProtocol {}
