import Foundation

protocol PlaylistCRUD {
    
    func addTrack(_ file: URL) throws -> Int
    
    func removeTrack(_ index: Int)
    
    // Clears the entire playlist of all tracks
    func clear()
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(_ index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(_ index: Int) -> Int
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // For a given search query, returns all tracks that match the query
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
    
    func isEmpty() -> Bool
    
    func size() -> Int
    
    func totalDuration() -> Double
    
    // Returns the currently playing track in the playlist
    func getPlayingTrack() -> IndexedTrack?
    
    func getPersistentState() -> PlaylistState
}
