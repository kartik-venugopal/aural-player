/*
    Contract for a class that performs CRUD operations on a playlist
 */

import Cocoa

protocol AuralPlaylistControlDelegate {
 
    // Add tracks (or saved playlists) to the current player playlist
    func addTracks(_ files: [URL])
    
    // Removes a single track at the specified index in the playlist. Returns the playing track index after removal (nil if playing track is the one removed)
    func removeTrack(_ index: Int) -> Int?
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(_ index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(_ index: Int) -> Int
    
    // Clears the entire player playlist of all tracks
    func clearPlaylist()
    
    // Saves the current player playlist to a file
    func savePlaylist(_ file: URL)
    
    // Retrieves a summary of the current playlist - the total number of tracks and their total duration
    func getPlaylistSummary() -> (numTracks: Int, totalDuration: Double)
    
    // Toggles between repeat modes. See RepeatMode for more details.
    func toggleRepeatMode() -> RepeatMode
    
    // Toggles between shuffle modes. See ShuffleMode for more details.
    func toggleShuffleMode() -> ShuffleMode
    
    // For a given search query, returns all tracks that match the query
    func searchTracks(searchQuery: SearchQuery) -> SearchResults
}
