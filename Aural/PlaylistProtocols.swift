import Foundation

protocol PlaylistAccessorProtocol {
    
    func getTracks() -> [Track]
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    func indexOfTrack(_ track: Track?) -> Int?
    
    func size() -> Int
    
    func totalDuration() -> Double
    
    func summary() -> (size: Int, totalDuration: Double)
    
    // For a given search query, returns all tracks that match the query
    func search(_ searchQuery: SearchQuery) -> SearchResults
}

protocol PlaylistMutatorProtocol {
    
    func addTrack(_ track: Track) -> Int
    
    func removeTrack(_ index: Int)
    
    // Clears the entire playlist of all tracks
    func clear()
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(_ index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(_ index: Int) -> Int
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}

protocol PlaylistCRUDProtocol: PlaylistAccessorProtocol, PlaylistMutatorProtocol {
}
