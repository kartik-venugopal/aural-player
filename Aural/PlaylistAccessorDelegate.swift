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
    
    func allTracks() -> [Track] {
        return playlist.allTracks()
    }
    
    func trackAtIndex(_ index: Int?) -> IndexedTrack? {
        return playlist.trackAtIndex(index)
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
    
    func groupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack {
        return playlist.groupingInfoForTrack(groupType, track)
    }
    
    func displayNameForTrack(_ type: GroupType, _ track: Track) -> String {
        return playlist.displayNameForTrack(type, track)
    }
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group {
        return playlist.groupAtIndex(type, index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return playlist.groupingInfoForTrack(type, track)
    }
    
    func indexOfGroup(_ group: Group) -> Int {
        return playlist.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return playlist.numberOfGroups(type)
    }
}
