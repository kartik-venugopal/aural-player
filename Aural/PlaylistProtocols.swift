import Foundation

/*
    Contract for read-only playlist operations
 */
protocol PlaylistAccessorProtocol: CommonPlaylistAccessorProtocol {
    
    // Retrieve all tracks
    func getTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track) -> Int?
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
    
    // Returns a summary of the playlist - both size and total duration
    func summary() -> (size: Int, totalDuration: Double)
    
    func getGroupAt(_ type: GroupType, _ index: Int) -> Group
    
    func getNumberOfGroups(_ type: GroupType) -> Int
    
    func getGroupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack
    
    func getIndexOf(_ group: Group) -> Int
    
    func displayNameFor(_ type: GroupType, _ track: Track) -> String
}

/*
    Contract for mutating/write playlist operations
 */
protocol PlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns information about its location within the playlist
    func addTrack(_ track: Track) -> TrackAddResult?
    
    // Removes tracks with the given indexes
    func removeTracks(_ indexes: IndexSet) -> RemoveOperationResults
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> RemoveOperationResults
    
    // See FlatPlaylistMutatorProtocol.moveTracksUp()
    func moveTracksUp(_ indexes: IndexSet) -> [Int: Int]
    
    // See FlatPlaylistMutatorProtocol.moveTracksDown()
    func moveTracksDown(_ indexes: IndexSet) -> [Int: Int]
    
    // Performs a sequence of playlist reorder operations
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation])
    
    // Notifies the playlist that info for this track has changed. The playlist may use the updates to re-group the track (by artist/album/genre, etc).
    func trackInfoUpdated(_ updatedTrack: Track)
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
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}
