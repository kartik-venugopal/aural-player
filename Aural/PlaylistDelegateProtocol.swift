/*
    Contract for a class that performs CRUD operations on a playlist
 */

import Cocoa

protocol PlaylistDelegateProtocol {
 
    // Add files (i.e. audio files, directories, or saved playlists) to the current playlist. Only supported audio files will be added.
    func addFiles(_ files: [URL])
    
    // Removes a single track at the specified index in the playlist. Returns the playing track index after removal (nil if playing track is the one removed)
    func removeTrack(_ index: Int) -> Int?
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(_ index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(_ index: Int) -> Int
    
    // Clears the entire playlist of all tracks
    func clearPlaylist()
    
    // Saves the current playlist to a file
    func savePlaylist(_ file: URL)
    
    // Retrieves a summary of the current playlist - the total number of tracks and their total duration
    func getPlaylistSummary() -> (numTracks: Int, totalDuration: Double)
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // For a given search query, returns all tracks that match the query
    func searchPlaylist(searchQuery: SearchQuery) -> SearchResults
    
    // Sorts the playlist according to the specified sort parameters
    func sortPlaylist(sort: Sort)
}
