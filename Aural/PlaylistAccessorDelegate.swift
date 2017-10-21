import Foundation

/*
    Concrete implementation of PlaylistAccessorDelegateProtocol
 */
class PlaylistAccessorDelegate: PlaylistAccessorDelegateProtocol {
    func getGroupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> (group: Group, groupIndex: Int, trackIndex: Int) {
        
        return (Group(.artist, ""), 1, 1)
    }

    
    // The actual playlist
    private let playlist: PlaylistAccessorProtocol
    
    init(_ playlist: PlaylistAccessorProtocol) {
        self.playlist = playlist
    }
    
    func getTracks() -> [Track] {
        return playlist.getTracks()
    }
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        return playlist.peekTrackAt(index)
    }
    
    func size() -> Int {
        return playlist.size()
    }
    
    func totalDuration() -> Double {
        return playlist.totalDuration()
    }
    
    func summary() -> (size: Int, totalDuration: Double) {
        return (playlist.size(), playlist.totalDuration())
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return playlist.search(searchQuery)
    }
}
