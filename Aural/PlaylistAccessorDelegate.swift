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
    
    func indexOfTrack(_ track: Track) -> IndexedTrack? {
        
        if let index = playlist.indexOfTrack(track) {
            return IndexedTrack(track, index)
        }
        
        return nil
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
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        return playlist.summary(playlistType)
    }
    
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        return playlist.search(searchQuery, playlistType)
    }
    
    func groupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack {
        return playlist.groupingInfoForTrack(groupType, track)
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        return playlist.displayNameForTrack(playlistType, track)
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
    
    func getGapForTrack(_ index: Int) -> PlaybackGap? {
        return playlist.getGapForTrack(index)
    }
    
    func getGapForTrack(_ track: Track) -> PlaybackGap? {
        return playlist.getGapForTrack(track)
    }
}
