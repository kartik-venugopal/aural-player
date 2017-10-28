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
    
    private func doSearch(_ query: SearchQuery, _ groupType: GroupType? = nil) -> SearchResults {
        
        // Smart search. Depending on query options, search either flat playlist or one of the grouped playlists. For ex, if searching by artist, it makes sense to search "Artists" playlist. Also, can split up the search into multiple parts, send them to different playlists, and put results together
        
        var allResults: SearchResults = SearchResults([])
        
        if (query.fields.name || query.fields.title) {
            allResults = flatPlaylist.search(query)
        }
        
        if (query.fields.artist) {
            
            let resultsByArtist = groupingPlaylists[.artist]!.search(query)
            allResults = allResults.union(resultsByArtist)
        }
        
        if (query.fields.album) {
            
            let resultsByAlbum = groupingPlaylists[.album]!.search(query)
            allResults = allResults.union(resultsByAlbum)
        }
        
        if let groupType = groupType {
            
            // Grouping playlist location
            
            for result in allResults.results {
                result.location.groupInfo = getGroupingInfoForTrack(groupType, result.location.track)
            }
            
        } else {
            
            // Flat playlist location
            
            for result in allResults.results {
                result.location.trackIndex = indexOfTrack(result.location.track)
            }
        }
        
        return allResults
    }
    
    func search(_ query: SearchQuery, _ groupType: GroupType) -> SearchResults {
        return doSearch(query, groupType)
    }
    
    func search(_ query: SearchQuery) -> SearchResults {
        return doSearch(query)
    }
    
    func sort(_ sort: Sort) {
        doSort(sort)
    }
    
    func sort(_ sort: Sort, _ groupType: GroupType) {
        doSort(sort, groupType)
    }
    
    private func doSort(_ sort: Sort, _ groupType: GroupType? = nil) {
        
        if let groupType = groupType {
            groupingPlaylists[groupType]!.sort(sort)
        } else {
            flatPlaylist.sort(sort)
        }
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
    
    func trackInfoUpdated(_ updatedTrack: Track) -> [GroupType: GroupedTrackUpdateResult] {
        
        var groupResults = [GroupType: GroupedTrackUpdateResult]()
        groupingPlaylists.values.forEach({groupResults[$0.getGroupType()] = $0.trackInfoUpdated(updatedTrack)})
        
        return groupResults
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
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMovedResults {
        return flatPlaylist.moveTracksDown(indexes)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMovedResults {
        return flatPlaylist.moveTracksUp(indexes)
    }
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        return flatPlaylist.peekTrackAt(index)
    }
    
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation]) {
        flatPlaylist.reorderTracks(reorderOperations)
    }
    
    func reorderTracks(_ reorderOperations: [GroupingPlaylistReorderOperation], _ groupType: GroupType) {
        groupingPlaylists[groupType]!.reorderTracks(reorderOperations)
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
        if let playlist = groupingPlaylists[type] {
        return playlist.getNumberOfGroups()
        }
        
        return 0
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> RemoveOperationResults {
        
        // Remove file/track mappings
        var removedTracks: [Track] = tracks
        groups.forEach({removedTracks.append(contentsOf: $0.tracks)})
        
        // Remove duplicates
        removedTracks = Array(Set(removedTracks))
        
        removedTracks.forEach({tracksByFilePath.removeValue(forKey: $0.file.path)})
        
        var groupingPlaylistResults = [GroupType: ItemRemovedResults]()
        
        // Remove from playlist with specified group type
        groupingPlaylistResults[groupType] = groupingPlaylists[groupType]!.removeTracksAndGroups(tracks, groups)
        
        // Remove from all other playlists
        
        groupingPlaylists.values.filter({$0.getGroupType() != groupType}).forEach({
            groupingPlaylistResults[$0.getGroupType()] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        let flatPlaylistIndexes = flatPlaylist.removeTracks(removedTracks)
        
        let results = RemoveOperationResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: flatPlaylistIndexes)
        
        return results
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMovedResults {
        return groupingPlaylists[groupType]!.moveTracksAndGroupsUp(tracks, groups)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMovedResults {
        return groupingPlaylists[groupType]!.moveTracksAndGroupsDown(tracks, groups)
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

struct GroupedTrackUpdateResult {
    
    let track: GroupedTrack
    let groupCreated: Bool
    let oldGroupRemoved: Bool
}

struct RemoveOperationResults {
    
    let groupingPlaylistResults: [GroupType: ItemRemovedResults]
    let flatPlaylistResults: IndexSet
}
