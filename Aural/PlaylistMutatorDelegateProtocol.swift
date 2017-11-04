import Cocoa

/*
    Contract for a middleman/delegate that relays mutating/write operations to the playlist
 */
protocol PlaylistMutatorDelegateProtocol {
    
    /* 
        Adds a set of files to the playlist, if they are valid and supported by the app.
     
        Each of the files can be one of the following:
        1 - A valid audio file with a supported format
        2 - A supported playlist file
        3 - A directory
     
        All playlists are expanded into their constituent tracks.
        All directories are traversed recursively, and all supported files within them are added in turn.
     
        Note - Duplicates are omitted (if a file already exists in the playlist, it will not be added).
     */
    func addFiles(_ files: [URL])
    
    // Removes track(s) with the given indexes
    // Returns true if 1 - a track was playing, AND 2 - the playing track was removed, false otherwise
    func removeTracks(_ indexes: IndexSet)
    
    // Returns true if 1 - a track was playing, AND 2 - the playing track was removed, false otherwise
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType)
    
    // Clears the entire playlist of all tracks
    func clear()
    
    /*
        Moves the tracks at the specified indexes, up one index, in the playlist, if they can be moved (they are not already at the top). Returns the new indexes of the tracks (for tracks that didn't move, the new index will match the old index)
    
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
    */
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves the tracks at the specified indexes, down one index, in the playlist, if they can be moved (they are not already at the bottom). Returns the new indexes of the tracks (for tracks that didn't move, the new index will match the old index)
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort, _ groupType: GroupType)
    
    func reorderTracksAndGroups(_ reorderOperations: [GroupingPlaylistReorderOperation], _ groupType: GroupType)
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet
}
