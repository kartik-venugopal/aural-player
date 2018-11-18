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
    
    var tracks: [Track] {return playlist.tracks}
    
    var size: Int {return playlist.size}
    
    var duration: Double {return playlist.duration}
    
    func indexOfTrack(_ track: Track) -> IndexedTrack? {
        
        if let index = playlist.indexOfTrack(track) {
            return IndexedTrack(track, index)
        }
        
        return nil
    }
    
    func trackAtIndex(_ index: Int?) -> IndexedTrack? {
        return playlist.trackAtIndex(index)
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
    
    func getGapsAroundTrack(_ track: Track) -> (hasGaps: Bool, beforeTrack: PlaybackGap?, afterTrack: PlaybackGap?) {
        
        let before = getGapBeforeTrack(track)
        let after = getGapAfterTrack(track)
        
        return ((before != nil || after != nil, before, after))
    }
    
    func getGapBeforeTrack(_ track: Track) -> PlaybackGap? {
        return playlist.getGapBeforeTrack(track)
    }
    
    func getGapAfterTrack(_ track: Track) -> PlaybackGap? {
        return playlist.getGapAfterTrack(track)
    }
}
