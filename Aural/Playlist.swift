/*
    Encapsulates all CRUD logic for a playlist
 */
import Foundation
import AVFoundation

class Playlist: PlaylistCRUDProtocol {
    
    private var flatPlaylist: FlatPlaylistCRUDProtocol
    private var groupingPlaylists: [GroupType: GroupingPlaylistCRUDProtocol] = [GroupType: GroupingPlaylist]()
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to avoid duplicates)
    private var tracksByFilePath: [String: Track] = [String: Track]()
    
    init(_ flatPlaylist: FlatPlaylistCRUDProtocol, _ groupingPlaylists: [GroupingPlaylistCRUDProtocol]) {
        
        self.flatPlaylist = flatPlaylist
        groupingPlaylists.forEach({self.groupingPlaylists[$0.getGroupType()] = $0})
    }
    
    func getTracks() -> [Track] {
        return flatPlaylist.getTracks()
    }
    
    func size() -> Int {
        return flatPlaylist.getTracks().count
    }
    
    func totalDuration() -> Double {
        
        let tracks = flatPlaylist.getTracks()
        var totalDuration: Double = 0
        
        tracks.forEach({totalDuration += $0.duration})
        
        return totalDuration
    }
    
    func summary() -> (size: Int, totalDuration: Double) {
        return (size(), totalDuration())
    }
    
    func addTrack(_ track: Track) -> TrackAddResult? {
        
        if (!trackExists(track)) {
            
            tracksByFilePath[track.file.path] = track
            
            let index = flatPlaylist.addTrackForIndex(track)!
            
            var groupingResults = [GroupType: GroupedTrackAddResult]()
            groupingPlaylists.values.forEach({groupingResults[$0.getGroupType()] = $0.addTrackForGroupInfo(track)})
            
            return TrackAddResult(flatPlaylistResult: index, groupingPlaylistResults: groupingResults)
        }
        
        return nil
    }
    
    // Checks whether or not a track with the given absolute file path already exists.
    private func trackExists(_ track: Track) -> Bool {
        return tracksByFilePath[track.file.path] != nil
    }
    
    func clear() {
        flatPlaylist.clear()
        groupingPlaylists.values.forEach({$0.clear()})
        tracksByFilePath.removeAll()
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        // Smart search. Depending on query options, search either flat playlist or one of the grouped playlists. For ex, if searching by artist, it makes sense to search "Artists" playlist. Also, can split up the search into multiple parts, send them to different playlists, and put results together
        
        return flatPlaylist.search(searchQuery)
    }
    
    func sort(_ sort: Sort) {
        flatPlaylist.sort(sort)
        groupingPlaylists.values.forEach({$0.sort(sort)})
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PlaylistState {
        
        let state = PlaylistState()
        let tracks = getTracks()
        
        for track in tracks {
            state.tracks.append(track.file)
        }
        
        return state
    }
    
    func trackInfoUpdated(_ updatedTrack: Track) {
//        groupings.values.forEach({$0.trackInfoUpdated(updatedTrack)})
        // TODO: Inform all the grouping playlists
    }
    
    func removeTracks(_ indexes: IndexSet) -> RemoveOperationResults {
        
        let removedTracks = flatPlaylist.removeTracks(indexes)
        removedTracks.forEach({tracksByFilePath.removeValue(forKey: $0.file.path)})
        
        var groupingPlaylistResults = [GroupType: ItemRemovedResults]()
        
        // Remove from all other playlists
        groupingPlaylists.values.forEach({
            groupingPlaylistResults[$0.getGroupType()] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        return RemoveOperationResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: indexes)
    }
    
    // ----------------------- FlatPlaylist protocols ----------------------------
    
    func indexOfTrack(_ track: Track) -> Int? {
        return flatPlaylist.indexOfTrack(track)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> [Int : Int] {
        return flatPlaylist.moveTracksDown(indexes)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> [Int : Int] {
        return flatPlaylist.moveTracksUp(indexes)
    }
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        return flatPlaylist.peekTrackAt(index)
    }
    
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation]) {
        flatPlaylist.reorderTracks(reorderOperations)
    }
    
    // ----------------------- GroupingPlaylist protocols ----------------------------
    
    func getGroupAt(_ type: GroupType, _ index: Int) -> Group {
        return groupingPlaylists[type]!.getGroupAt(index)
    }
    
    func getGroupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return groupingPlaylists[type]!.getGroupingInfoForTrack(track)
    }
    
    func getIndexOf(_ group: Group) -> Int {
        return groupingPlaylists[group.type]!.getIndexOf(group)
    }
    
    func getNumberOfGroups(_ type: GroupType) -> Int {
        return groupingPlaylists[type]!.getNumberOfGroups()
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> RemoveOperationResults {
        
        // Remove file/track mappings
        var removedTracks: [Track] = tracks
        groups.forEach({removedTracks.append(contentsOf: $0.tracks)})
        removedTracks.forEach({tracksByFilePath.removeValue(forKey: $0.file.path)})
        
        var groupingPlaylistResults = [GroupType: ItemRemovedResults]()
        
        // Remove from playlist with specified group type
        groupingPlaylistResults[groupType] = groupingPlaylists[groupType]!.removeTracksAndGroups(tracks, groups)
        
        // Remove from all other playlists
        
        groupingPlaylists.values.filter({$0.getGroupType() != groupType}).forEach({
            groupingPlaylistResults[$0.getGroupType()] = $0.removeTracksAndGroups(tracks, [])
        })
        
        let flatPlaylistIndexes = flatPlaylist.removeTracks(tracks)
        
        return RemoveOperationResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: flatPlaylistIndexes)
    }
    
    func displayNameFor(_ type: GroupType, _ track: Track) -> String {
        return groupingPlaylists[type]!.displayNameFor(track)
    }
}

struct TrackAddResult {
    
    let flatPlaylistResult: Int
    let groupingPlaylistResults: [GroupType: GroupedTrackAddResult]
}

struct GroupedTrackAddResult {
    
    let track: GroupedTrack
    let groupCreated: Bool
}

struct RemoveOperationResults {
    
    let groupingPlaylistResults: [GroupType: ItemRemovedResults]
    let flatPlaylistResults: IndexSet
}
