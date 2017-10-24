import Foundation

protocol GroupingPlaylistAccessorProtocol: CommonPlaylistAccessorProtocol {
    
    func getGroupAt(_ index: Int) -> Group
    
    func getNumberOfGroups() -> Int
    
    func getGroupType() -> GroupType
 
    func getGroupingInfoForTrack(_ track: Track) -> GroupedTrack
    
    func getIndexOf(_ group: Group) -> Int
    
    func displayNameFor(_ track: Track) -> String
}

protocol GroupingPlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist.
    func addTrackForGroupInfo(_ track: Track) -> GroupedTrackAddResult
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group]) -> ItemRemovedResults
    
    // Notifies the playlist that info for this track has changed. The playlist may use the updates to re-group the track (by artist/album/genre, etc).
    func trackInfoUpdated(_ updatedTrack: Track)
}

protocol GroupingPlaylistCRUDProtocol: GroupingPlaylistAccessorProtocol, GroupingPlaylistMutatorProtocol {}
