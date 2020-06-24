import Foundation

/*
    A facade providing unified access to all underlying playlist types (flat and grouping/hierarchical). Smartly delegates operations to the underlying playlists and aggregates results from those operations.
 */
class Playlist: PlaylistCRUDProtocol, PersistentModelObject {
    
    // Flat playlist
    private var flatPlaylist: FlatPlaylistCRUDProtocol
    
    // Hierarchical/grouping playlists (mapped by playlist type)
    private var groupingPlaylists: [PlaylistType: GroupingPlaylistCRUDProtocol] = [PlaylistType: GroupingPlaylist]()
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFilePath: [String: Track] = [String: Track]()
    
    private var gapsBefore: [Track: PlaybackGap] = [:]
    private var gapsAfter: [Track: PlaybackGap] = [:]
    
    init(_ flatPlaylist: FlatPlaylistCRUDProtocol, _ groupingPlaylists: [GroupingPlaylistCRUDProtocol]) {
        
        self.flatPlaylist = flatPlaylist
        groupingPlaylists.forEach({self.groupingPlaylists[$0.playlistType] = $0})
    }
    
    var tracks: [Track] {return flatPlaylist.tracks}
    
    var size: Int {return flatPlaylist.size}
    
    var duration: Double {return flatPlaylist.duration}
    
    func findTrackByFile(_ file: URL) -> Track? {
        return tracksByFilePath[file.path]
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        
        if (playlistType == .tracks) {
            return flatPlaylist.displayNameForTrack(track)
        }
        
        return groupingPlaylists[playlistType]!.displayNameForTrack(track)
    }
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        
        if (playlistType == .tracks) {
            
            // Tracks don't have any groups, so numGroups = 0
            return (size, duration, 0)
            
        } else {
            return (size, duration, groupingPlaylists[playlistType]!.numberOfGroups)
        }
    }
    
    func addTrack(_ track: Track) -> TrackAddResult? {
        
        if (!hasTrack(track)) {
            
            // Add a mapping by track's file path
            tracksByFilePath[track.file.path] = track
            
            // Add the track to the flat playlist and return the new track's index
            let index = flatPlaylist.addTrack(track)
            
            var groupingResults: [GroupType: GroupedTrackAddResult] = [:]
            
            // Add the track to each of the grouping playlists
            groupingPlaylists.values.forEach({groupingResults[$0.typeOfGroups] = $0.addTrack(track)})
            
            return TrackAddResult(track: track, flatPlaylistResult: index, groupingPlaylistResults: groupingResults)
        }
        
        return nil
    }
    
    func setGapsForTrack(_ track: Track, _ gapBeforeTrack: PlaybackGap?, _ gapAfterTrack: PlaybackGap?) {
        
        gapsBefore[track] = gapBeforeTrack
        gapsAfter[track] = gapAfterTrack
    }
    
    func removeGapsForTrack(_ track: Track) {
        
        gapsBefore.removeValue(forKey: track)
        gapsAfter.removeValue(forKey: track)
    }
    
    func removeGapForTrack(_ track: Track, _ gapPosition: PlaybackGapPosition) {
        _ = gapPosition == .beforeTrack ? gapsBefore.removeValue(forKey: track) : gapsAfter.removeValue(forKey: track)
    }
    
    func getGapBeforeTrack(_ track: Track) -> PlaybackGap? {
        return gapsBefore[track]
    }
    
    func getGapAfterTrack(_ track: Track) -> PlaybackGap? {
        return gapsAfter[track]
    }
    
    private var allGaps: (gapsBeforeTracks: [Track: PlaybackGap], gapsAfterTracks: [Track: PlaybackGap]) {
        return (gapsBefore, gapsAfter)
    }
    
    func clear() {
        
        // Clear each of the playlists
        flatPlaylist.clear()
        groupingPlaylists.values.forEach({$0.clear()})
        
        // Remove all the file path mappings
        tracksByFilePath.removeAll()
        gapsBefore.removeAll()
        gapsAfter.removeAll()
    }
    
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        
        // Smart search. Depending on query options, search either flat playlist or one of the grouping playlists. For ex, if searching by artist, it makes sense to search "Artists" playlist. Also, split up the search into multiple parts, send them to different playlists, and aggregate results together.
        
        // Union of results from each of the individual searches
        var allResults: SearchResults = SearchResults([])
        
        // The flat playlist searches by name or title
        if searchQuery.fields.name || searchQuery.fields.title {
            allResults = flatPlaylist.search(searchQuery)
        }
        
        // The Artists playlist searches only by artist
        if searchQuery.fields.artist, let artistsPlaylist = groupingPlaylists[.artists] {
            
            let resultsByArtist = artistsPlaylist.search(searchQuery)
            allResults = allResults.union(resultsByArtist)
        }
        
        // The Albums playlist searches only by album
        if searchQuery.fields.album, let albumsPlaylist = groupingPlaylists[.albums] {
            
            let resultsByAlbum = albumsPlaylist.search(searchQuery)
            allResults = allResults.union(resultsByAlbum)
        }
        
        // Determine locations for each of the result tracks, and sort results in ascending order by location
        // NOTE - Locations are specific to the playlist type. That's why they need to be determined after the searches are performed.
        if let groupType = playlistType.toGroupType() {
            
            // Grouping playlist locations
            
            for result in allResults.results {
                result.location.groupInfo = groupingInfoForTrack(groupType, result.location.track)
            }
            
            allResults = allResults.sortedByGroupAndTrackIndex()
            
        } else {
            
            // Flat playlist locations
            
            for result in allResults.results {
                result.location.trackIndex = indexOfTrack(result.location.track)
            }
            
            allResults = allResults.sortedByTrackIndex()
        }
        
        return allResults
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) -> SortResults {
        
        // The results are independent of specific reordering operations, so they can be determined before the playlist is actually sorted.
        let results = SortResults(playlistType, sort)
        
        // Sort only the specified playlist type
        
        if playlistType == .tracks {
            
            flatPlaylist.sort(sort)
            
        } else if let groupingPlaylist = groupingPlaylists[playlistType] {
            
            groupingPlaylist.sort(sort)
        }
        
        return results
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PersistentState {
        
        let state = PlaylistState()
        let gaps = allGaps
        
        tracks.forEach({state.tracks.append($0.file)})
        
        gaps.gapsBeforeTracks.forEach({
            
            if $0.value.type == .persistent {
                
                let gapState = PlaybackGapState()
                gapState.track = $0.key.file
                gapState.duration = $0.value.duration
                gapState.position = $0.value.position
                gapState.type = $0.value.type
                
                state.gaps.append(gapState)
            }
        })
        
        gaps.gapsAfterTracks.forEach({
            
            if $0.value.type == .persistent {
                
                let gapState = PlaybackGapState()
                gapState.track = $0.key.file
                gapState.duration = $0.value.duration
                gapState.position = $0.value.position
                gapState.type = $0.value.type
                
                state.gaps.append(gapState)
            }
        })
        
        return state
    }
    
    // MARK: Flat playlist functions
    
    func removeTracks(_ indexes: IndexSet) -> TrackRemovalResults {
        
        // Remove tracks from flat playlist
        let removedTracks = flatPlaylist.removeTracks(indexes)
        
        // Remove secondary state associated with these tracks
        removedTracks.forEach({
            
            tracksByFilePath.removeValue(forKey: $0.file.path)
            gapsBefore.removeValue(forKey: $0)
            gapsAfter.removeValue(forKey: $0)
        })
        
        var groupingPlaylistResults = [GroupType: [ItemRemovalResult]]()
        
        // Remove tracks from all other playlists
        groupingPlaylists.values.forEach({
            groupingPlaylistResults[$0.typeOfGroups] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        return TrackRemovalResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: indexes, tracks: removedTracks)
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        
        if tracksByFilePath[track.file.path] == nil {return nil}
        
        return flatPlaylist.indexOfTrack(track)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        return tracksByFilePath[track.file.path] != nil
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        return flatPlaylist.moveTracksDown(indexes)
    }
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults {
        return flatPlaylist.moveTracksToBottom(indexes)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        return flatPlaylist.moveTracksUp(indexes)
    }
    
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults {
        return flatPlaylist.moveTracksToTop(indexes)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return flatPlaylist.trackAtIndex(index)
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> IndexSet {
        return flatPlaylist.dropTracks(sourceIndexes, dropIndex)
    }
    
    // MARK: Grouping/hierarchical playlist functions
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group? {
        return groupingPlaylists[type.toPlaylistType()]?.groupAtIndex(index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack? {
        return groupingPlaylists[type.toPlaylistType()]!.groupingInfoForTrack(track)
    }
    
    func indexOfGroup(_ group: Group) -> Int? {
        return groupingPlaylists[group.type.toPlaylistType()]?.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return groupingPlaylists[type.toPlaylistType()]!.numberOfGroups
    }
    
    func allGroupingInfoForTrack(_ track: Track) -> [GroupType : GroupedTrack] {
        
        var groupingResults = [GroupType: GroupedTrack]()
        
        // Add the track to each of the grouping playlists
        groupingPlaylists.values.forEach({

            if let info = $0.groupingInfoForTrack(track) {
                groupingResults[$0.typeOfGroups] = info
            }
        })
        
        // Return the results of the add operation
        return groupingResults
    }
    
    func allGroups(_ type: GroupType) -> [Group] {
        
        if let groupingPlaylist = groupingPlaylists[type.toPlaylistType()] {
            return groupingPlaylist.groups
        }
        
        return []
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> TrackRemovalResults {
        
        // Remove file/track mappings
        var removedTracks: [Track] = tracks
        groups.forEach({removedTracks.append(contentsOf: $0.allTracks())})
        
        // Remove duplicates
        removedTracks = Array(Set(removedTracks))
        
        // Remove secondary state associated with these tracks
        removedTracks.forEach({
            
            tracksByFilePath.removeValue(forKey: $0.file.path)
            gapsBefore.removeValue(forKey: $0)
            gapsAfter.removeValue(forKey: $0)
        })
        
        var groupingPlaylistResults = [GroupType: [ItemRemovalResult]]()
        
        // Remove from playlist with specified group type
        groupingPlaylistResults[groupType] = groupingPlaylists[groupType.toPlaylistType()]!.removeTracksAndGroups(tracks, groups)
        
        // Remove from all other playlists
        
        groupingPlaylists.values.filter({$0.typeOfGroups != groupType}).forEach({
            groupingPlaylistResults[$0.typeOfGroups] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        let flatPlaylistIndexes = flatPlaylist.removeTracks(removedTracks)
        
        let results = TrackRemovalResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: flatPlaylistIndexes, tracks: removedTracks)
        
        return results
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.moveTracksAndGroupsUp(tracks, groups)
    }
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.moveTracksAndGroupsToTop(tracks, groups)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.moveTracksAndGroupsDown(tracks, groups)
    }
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.moveTracksAndGroupsToBottom(tracks, groups)
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        return groupingPlaylists[groupType.toPlaylistType()]!.dropTracksAndGroups(tracks, groups, dropParent, dropIndex)
    }
}
