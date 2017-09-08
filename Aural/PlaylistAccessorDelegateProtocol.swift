import Foundation

protocol PlaylistAccessorDelegateProtocol {
    
    func getTracks() -> [Track]
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    func size() -> Int
    
    func totalDuration() -> Double
    
    func summary() -> (size: Int, totalDuration: Double)
    
    // For a given search query, returns all tracks that match the query
    func search(_ searchQuery: SearchQuery) -> SearchResults
}
