import Foundation

/*
    Contract for read-only playlist operations
 */
protocol PlaylistAccessorProtocol {
    
    // Retrieve all tracks
    func allTracks() -> [Track]
    
    // Read the track at a given index. Nil if invalid index is specified.
    func trackAtIndex(_ index: Int?) -> IndexedTrack?
    
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track) -> Int?
    
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
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group
    
    func numberOfGroups(_ type: GroupType) -> Int
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack
    
    func indexOfGroup(_ group: Group) -> Int
    
    func displayNameForTrack(_ type: GroupType, _ track: Track) -> String
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery, _ groupType: GroupType) -> SearchResults
}

/*
    Contract for mutating/write playlist operations
 */
protocol PlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns information about its location within the playlist
    func addTrack(_ track: Track) -> TrackAddResult?
    
    // Removes tracks with the given indexes
    func removeTracks(_ indexes: IndexSet) -> TrackRemovalResults
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> TrackRemovalResults
    
    // See FlatPlaylistMutatorProtocol.moveTracksUp()
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    // See FlatPlaylistMutatorProtocol.moveTracksDown()
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    // Performs a sequence of playlist reorder operations
    func reorderTracks(_ reorderOperations: [FlatPlaylistReorderOperation])
    
    func reorderTracksAndGroups(_ reorderOperations: [GroupingPlaylistReorderOperation], _ groupType: GroupType)
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort, _ groupType: GroupType)
}

/*
    Contract for all read-only and mutating/write playlist operations
 */
protocol PlaylistCRUDProtocol: PlaylistAccessorProtocol, PlaylistMutatorProtocol {
}

protocol CommonPlaylistMutatorProtocol {
    
    // Clears the entire playlist of all tracks
    func clear()
}
