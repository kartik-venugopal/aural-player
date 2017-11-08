/*
    Encapsulates all CRUD logic for a playlist
 */
import Foundation
import AVFoundation

class Playlist: PlaylistCRUDProtocol {
    
    private var flatPlaylist: FlatPlaylistCRUDProtocol
    private var groupingPlaylists: [PlaylistType: GroupingPlaylistCRUDProtocol] = [PlaylistType: GroupingPlaylist]()
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFilePath: [String: Track] = [String: Track]()
    
    init(_ flatPlaylist: FlatPlaylistCRUDProtocol, _ groupingPlaylists: [GroupingPlaylistCRUDProtocol]) {
        
        self.flatPlaylist = flatPlaylist
        groupingPlaylists.forEach({self.groupingPlaylists[$0.playlistType()] = $0})
    }
    
    func allTracks() -> [Track] {
        let copy = flatPlaylist.allTracks()
        return copy
    }
    
    func size() -> Int {
        return flatPlaylist.size()
    }
    
    func totalDuration() -> Double {
        return flatPlaylist.totalDuration()
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        
        if (playlistType == .tracks) {
            return flatPlaylist.displayNameForTrack(track)
        }
        
        return groupingPlaylists[playlistType]!.displayNameForTrack(track)
    }
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        
        if (playlistType == .tracks) {
            return (size(), totalDuration(), 0)
        } else {
            return (size(), totalDuration(), groupingPlaylists[playlistType]!.numberOfGroups())
        }
    }
    
    func addTrack(_ track: Track) -> TrackAddResult? {
        
        if (!trackExists(track)) {
            
            tracksByFilePath[track.file.path] = track
            
            let index = flatPlaylist.addTrack(track)
            
            var groupingResults = [GroupType: GroupedTrackAddResult]()
            groupingPlaylists.values.forEach({groupingResults[$0.typeOfGroups()] = $0.addTrack(track)})
            
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
    
    private func doSearch(_ query: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        
        // Smart search. Depending on query options, search either flat playlist or one of the grouped playlists. For ex, if searching by artist, it makes sense to search "Artists" playlist. Also, can split up the search into multiple parts, send them to different playlists, and put results together
        
        var allResults: SearchResults = SearchResults([])
        
        if (query.fields.name || query.fields.title) {
            allResults = flatPlaylist.search(query)
        }
        
        if (query.fields.artist) {
            
            let resultsByArtist = groupingPlaylists[.artists]!.search(query)
            allResults = allResults.union(resultsByArtist)
        }
        
        if (query.fields.album) {
            
            let resultsByAlbum = groupingPlaylists[.albums]!.search(query)
            allResults = allResults.union(resultsByAlbum)
        }
        
        if let groupType = playlistType.toGroupType() {
            
            // Grouping playlist location
            
            for result in allResults.results {
                result.location.groupInfo = groupingInfoForTrack(groupType, result.location.track)
            }
            
            allResults = allResults.sortedByGroupAndTrackIndex()
            
        } else {
            
            // Flat playlist location
            
            for result in allResults.results {
                result.location.trackIndex = indexOfTrack(result.location.track)
            }
            
            allResults = allResults.sortedByTrackIndex()
        }
        
        return allResults
    }
    
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        return doSearch(searchQuery, playlistType)
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) {

        if playlistType == .tracks {
            flatPlaylist.sort(sort)
        } else {
            groupingPlaylists[playlistType]!.sort(sort)
        }
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PlaylistState {
        
        let state = PlaylistState()
        let tracks = allTracks()
        
        tracks.forEach({state.tracks.append($0.file)})
        
        return state
    }
    
    // ----------------------- FlatPlaylist functions ----------------------------
    
    func removeTracks(_ indexes: IndexSet) -> TrackRemovalResults {
        
        let removedTracks = flatPlaylist.removeTracks(indexes)
        removedTracks.forEach({tracksByFilePath.removeValue(forKey: $0.file.path)})
        
        var groupingPlaylistResults = [GroupType: [ItemRemovalResult]]()
        
        // Remove from all other playlists
        groupingPlaylists.values.forEach({
            groupingPlaylistResults[$0.typeOfGroups()] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        return TrackRemovalResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: indexes)
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return flatPlaylist.indexOfTrack(track)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        return flatPlaylist.moveTracksDown(indexes)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        return flatPlaylist.moveTracksUp(indexes)
    }
    
    func trackAtIndex(_ index: Int?) -> IndexedTrack? {
        return flatPlaylist.trackAtIndex(index)
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet {
        return flatPlaylist.dropTracks(sourceIndexes, dropIndex, dropType)
    }
    
    // ----------------------- GroupingPlaylist functions ----------------------------
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group {
        return groupingPlaylists[type.toPlaylistType()]!.groupAtIndex(index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return groupingPlaylists[type.toPlaylistType()]!.groupingInfoForTrack(track)
    }
    
    func indexOfGroup(_ group: Group) -> Int {
        return groupingPlaylists[group.type.toPlaylistType()]!.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return groupingPlaylists[type.toPlaylistType()]!.numberOfGroups()
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> TrackRemovalResults {
        
        // Remove file/track mappings
        var removedTracks: [Track] = tracks
        groups.forEach({removedTracks.append(contentsOf: $0.allTracks())})
        
        // Remove duplicates
        removedTracks = Array(Set(removedTracks))
        
        removedTracks.forEach({tracksByFilePath.removeValue(forKey: $0.file.path)})
        
        var groupingPlaylistResults = [GroupType: [ItemRemovalResult]]()
        
        // Remove from playlist with specified group type
        groupingPlaylistResults[groupType] = groupingPlaylists[groupType.toPlaylistType()]!.removeTracksAndGroups(tracks, groups)
        
        // Remove from all other playlists
        
        groupingPlaylists.values.filter({$0.typeOfGroups() != groupType}).forEach({
            groupingPlaylistResults[$0.typeOfGroups()] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        let flatPlaylistIndexes = flatPlaylist.removeTracks(removedTracks)
        
        let results = TrackRemovalResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: flatPlaylistIndexes)
        
        return results
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.moveTracksAndGroupsUp(tracks, groups)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.moveTracksAndGroupsDown(tracks, groups)
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        return groupingPlaylists[groupType.toPlaylistType()]!.dropTracksAndGroups(tracks, groups, dropParent, dropIndex)
    }
}
