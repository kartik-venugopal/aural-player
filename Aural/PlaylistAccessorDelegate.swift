import Foundation

/*
    Concrete implementation of PlaylistAccessorDelegateProtocol
 */
class PlaylistAccessorDelegate: PlaylistAccessorDelegateProtocol {
    
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
        return playlist.summary()
    }
    
    func summary(_ groupType: GroupType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        return playlist.summary(groupType)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return playlist.search(searchQuery)
    }
    
    func search(_ searchQuery: SearchQuery, _ groupType: GroupType) -> SearchResults {
        return playlist.search(searchQuery, groupType)
    }
    
    func getGroupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack {
        return playlist.getGroupingInfoForTrack(groupType, track)
    }
    
    func displayNameFor(_ type: GroupType, _ track: Track) -> String {
        return playlist.displayNameFor(type, track)
    }
    
    func getGroupAt(_ type: GroupType, _ index: Int) -> Group {
        return playlist.getGroupAt(type, index)
    }
    
    func getGroupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return playlist.getGroupingInfoForTrack(type, track)
    }
    
    func getIndexOf(_ group: Group) -> Int {
        return playlist.getIndexOf(group)
    }
    
    func getNumberOfGroups(_ type: GroupType) -> Int {
        return playlist.getNumberOfGroups(type)
    }
}
