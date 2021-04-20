import Foundation

/*
    A facade providing unified access to all underlying playlist types (flat and grouping/hierarchical). Smartly delegates operations to the underlying playlists and aggregates results from those operations.
 */
class Playlist: PlaylistCRUDProtocol {
    
    // Flat playlist
    private var flatPlaylist: FlatPlaylistCRUDProtocol
    
    // Hierarchical/grouping playlists (mapped by playlist type)
    var groupingPlaylists: [PlaylistType: GroupingPlaylistCRUDProtocol] = [:]
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFile: [URL: Track] = [:]
    
    init(_ flatPlaylist: FlatPlaylistCRUDProtocol, _ groupingPlaylists: [GroupingPlaylistCRUDProtocol]) {
        
        self.flatPlaylist = flatPlaylist
        groupingPlaylists.forEach({self.groupingPlaylists[$0.playlistType] = $0})
    }
    
    var tracks: [Track] {flatPlaylist.tracks}
    
    var size: Int {flatPlaylist.size}
    
    var duration: Double {flatPlaylist.duration}
    
    func findTrackByFile(_ file: URL) -> Track? {
        return tracksByFile[file]
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        
        return playlistType == .tracks ?
            flatPlaylist.displayNameForTrack(track) :
            groupingPlaylists[playlistType]!.displayNameForTrack(track)
    }
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        
        return playlistType == .tracks ?
            (size, duration, 0) :
            (size, duration, groupingPlaylists[playlistType]!.numberOfGroups)
    }
    
    func addTrack(_ track: Track) -> TrackAddResult? {
        
        guard !hasTrack(track) else {return nil}
        
        // Add a mapping by track's file path
        tracksByFile[track.file] = track
        
        // Add the track to the flat playlist
        let index = flatPlaylist.addTrack(track)
        
        // Add the track to each of the grouping playlists
        var groupingResults: [GroupType: GroupedTrackAddResult] = [:]
        groupingPlaylists.values.forEach({groupingResults[$0.typeOfGroups] = $0.addTrack(track)})
        
        return TrackAddResult(track: track, flatPlaylistResult: index, groupingPlaylistResults: groupingResults)
    }
    
    func clear() {
        
        // Clear each of the playlists
        flatPlaylist.clear()
        groupingPlaylists.values.forEach({$0.clear()})
        
        // Remove all the file path mappings
        tracksByFile.removeAll()
    }

    // Smart search. Depending on query options, search either flat playlist or one of the grouping playlists. For ex, if searching by artist, it makes sense to search "Artists" playlist. Also, split up the search into multiple parts, send them to different playlists, and aggregate results together.
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        
        // Union of results from each of the individual searches
        var allResults: SearchResults = SearchResults([])
        
        // The flat playlist searches by name or title
        if searchQuery.fields.name || searchQuery.fields.title {
            allResults = flatPlaylist.search(searchQuery)
        }
        
        // The Artists playlist searches only by artist
        if searchQuery.fields.artist, let artistsPlaylist = groupingPlaylists[.artists] {
            allResults.performUnionWith(artistsPlaylist.search(searchQuery))
        }
        
        // The Albums playlist searches only by album
        if searchQuery.fields.album, let albumsPlaylist = groupingPlaylists[.albums] {
            allResults.performUnionWith(albumsPlaylist.search(searchQuery))
        }
        
        // Determine locations for each of the result tracks, within the given playlist type, and sort results in ascending order by location
        // NOTE - Locations are specific to the playlist type. That's why they need to be determined after the searches are performed.
        if let groupType = playlistType.toGroupType() {
            
            // Grouping playlist locations
            allResults.results.forEach({$0.location.groupInfo = groupingInfoForTrack(groupType, $0.location.track)})
            allResults.sortByGroupAndTrackIndex()
            
        } else {
            
            // Flat playlist locations
            allResults.results.forEach({$0.location.trackIndex = indexOfTrack($0.location.track)})
            allResults.sortByTrackIndex()
        }
        
        return allResults
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) -> SortResults {
        
        // Sort only the specified playlist type
        playlistType == .tracks ? flatPlaylist.sort(sort) : groupingPlaylists[playlistType]!.sort(sort)

        // The results are independent of specific reordering operations
        return SortResults(playlistType, sort)
    }
    
    // MARK: Flat playlist functions
    
    func removeTracks(_ indexes: IndexSet) -> TrackRemovalResults {
        
        // Remove tracks from flat playlist
        let removedTracks = flatPlaylist.removeTracks(indexes)
        
        // Remove secondary state associated with these tracks
        removedTracks.forEach {
            tracksByFile.removeValue(forKey: $0.file)
        }
        
        // Remove tracks from all other playlists
        var groupingPlaylistResults = [GroupType: [GroupedItemRemovalResult]]()
        groupingPlaylists.values.forEach({
            groupingPlaylistResults[$0.typeOfGroups] = $0.removeTracksAndGroups(removedTracks, [])
        })
        
        return TrackRemovalResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: indexes, tracks: removedTracks)
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return flatPlaylist.indexOfTrack(track)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        return tracksByFile[track.file] != nil
    }
    
    func hasTrackForFile(_ file: URL) -> Bool {
        return tracksByFile[file] != nil
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
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        return flatPlaylist.dropTracks(sourceIndexes, dropIndex)
    }
    
    // MARK: Grouping/hierarchical playlist functions
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group? {
        return groupingPlaylists[type.toPlaylistType()]?.groupAtIndex(index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack? {
        return groupingPlaylists[type.toPlaylistType()]?.groupingInfoForTrack(track)
    }
    
    func indexOfGroup(_ group: Group) -> Int? {
        return groupingPlaylists[group.type.toPlaylistType()]?.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return groupingPlaylists[type.toPlaylistType()]?.numberOfGroups ?? 0
    }
    
    func allGroupingInfoForTrack(_ track: Track) -> [GroupType : GroupedTrack] {
        
        var groupingResults = [GroupType: GroupedTrack]()
        
        // Add the track to each of the grouping playlists
        groupingPlaylists.values.compactMap {$0.groupingInfoForTrack(track)}.forEach({
            groupingResults[$0.group.type] = $0
        })
        
        return groupingResults
    }
    
    func allGroups(_ type: GroupType) -> [Group] {
        return groupingPlaylists[type.toPlaylistType()]!.groups
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> TrackRemovalResults {
        
        // Flatten the groups into their tracks, removing duplicates (the same track being added individually and from its parent group)
        let removedTracks: [Track] = Array(Set(tracks + groups.flatMap {$0.allTracks()}))
        
        // Remove secondary state associated with these tracks
        removedTracks.forEach {
            tracksByFile.removeValue(forKey: $0.file)
        }
        
        var groupingPlaylistResults = [GroupType: [GroupedItemRemovalResult]]()
        
        // Remove from grouping playlist with specified group type
        groupingPlaylistResults[groupType] = groupingPlaylists[groupType.toPlaylistType()]!.removeTracksAndGroups(tracks, groups)
        
        // Remove from all other grouping playlists
        groupingPlaylists.values.filter({$0.typeOfGroups != groupType}).forEach({
            groupingPlaylistResults[$0.typeOfGroups] = $0.removeTracksAndGroups(removedTracks, [])
        })

        // Remove from flat playlist
        let flatPlaylistResults: IndexSet = flatPlaylist.removeTracks(removedTracks)
        
        return TrackRemovalResults(groupingPlaylistResults: groupingPlaylistResults, flatPlaylistResults: flatPlaylistResults, tracks: removedTracks)
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
    
    private let reorderOpQueue: OperationQueue = {

        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInteractive
        
        return queue
    }()
    
    func reOrder(accordingTo state: PlaylistState) {
        
        // Re-order each of the grouping playlists.
        // NOTE - The flat playlist does not need to be reordered,
        // because it is already in the correct order.
        
        for (type, playlist) in groupingPlaylists {
            
            if let playlistState = state.groupingPlaylists[type.rawValue] {

                // The different grouping playlists can be reordered in parallel,
                // because the reorder operations are independent of each other.
                // In other words, reordering one grouping playlist does not
                // affect any other grouping playlist.
                
                reorderOpQueue.addOperation {
                    playlist.reOrder(accordingTo: playlistState)
                }
            }
        }
        
        reorderOpQueue.waitUntilAllOperationsAreFinished()
    }
}
