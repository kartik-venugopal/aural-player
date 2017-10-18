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
    func removeTracks(_ indexes: [Int])
    
    // Clears the entire playlist of all tracks
    func clear()
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(_ index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(_ index: Int) -> Int
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
    
    // Performs a sequence of playlist reorder operations
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation])
}
