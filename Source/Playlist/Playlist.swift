//
//  Playlist.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A facade for all operations pertaining to the playlist. Delegates operations to the underlying
/// playlists (flat and grouping/hierarchical), and aggregates results from those operations.
///
class Playlist: PlaylistProtocol {
    
    // Flat playlist
    private var flatPlaylist: FlatPlaylistProtocol
    
    // Hierarchical/grouping playlists (mapped by playlist type)
    var groupingPlaylists: [PlaylistType: GroupingPlaylistProtocol] = [:]
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFile: [URL: Track] = [:]
    
    init(_ flatPlaylist: FlatPlaylistProtocol, _ groupingPlaylists: [GroupingPlaylistProtocol]) {
        
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
        if searchQuery.fields.containsOneOf(.name, .title) {
            
            allResults = flatPlaylist.search(searchQuery)
        }
        
        // The Artists playlist searches only by artist
        if searchQuery.fields.contains(.artist), let artistsPlaylist = groupingPlaylists[.artists] {
            
            allResults.performUnionWith(artistsPlaylist.search(searchQuery))
        }
        
        // The Albums playlist searches only by album
        if searchQuery.fields.contains(.album), let albumsPlaylist = groupingPlaylists[.albums] {
            
            allResults.performUnionWith(albumsPlaylist.search(searchQuery))
        }
        
        // Determine locations for each of the result tracks, within the given playlist type, and sort results in ascending order by location
        // NOTE - Locations are specific to the playlist type. A playlist that reports a match is not necessarily the same as the given playlist type. That's why locations need to be determined after the searches are performed.
        
        if let groupType = playlistType.toGroupType() {
            
            // Grouping playlist locations
            allResults.results.forEach {$0.location.groupInfo = groupingInfoForTrack(groupType, $0.location.track)}
            allResults.sortByGroupAndTrackIndex()
            
        } else {
            
            // Flat playlist locations
            allResults.results.forEach {
                
                if $0.location.trackIndex == nil {
                    $0.location.trackIndex = indexOfTrack($0.location.track)
                }
            }
            
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
        
        return TrackRemovalResults(tracks: removedTracks, flatPlaylistResults: indexes,
                                   groupingPlaylistResults: groupingPlaylistResults)
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
        let removedTracksSet: Set<Track> = Set(tracks + groups.flatMap {$0.tracks})
        let removedTracks: [Track] = Array(removedTracksSet)
        
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
        
        return TrackRemovalResults(tracks: removedTracks, flatPlaylistResults: flatPlaylistResults,
                                   groupingPlaylistResults: groupingPlaylistResults)
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
    
    private let opQueue: OperationQueue = {

        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInteractive
        
        return queue
    }()
    
    func reOrder(accordingTo state: PlaylistPersistentState) {
        
        // Re-order each of the grouping playlists.
        // NOTE - The flat playlist does not need to be reordered,
        // because it is already in the correct order.
        
        for (type, playlist) in groupingPlaylists {
            
            if let playlistState = state.groupingPlaylists?[type.rawValue] {

                // The different grouping playlists can be reordered in parallel,
                // because the reorder operations are independent of each other.
                // In other words, reordering one grouping playlist does not
                // affect any other grouping playlist.
                
                opQueue.addOperation {
                    playlist.reOrder(accordingTo: playlistState)
                }
            }
        }
        
        opQueue.waitUntilAllOperationsAreFinished()
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PlaylistPersistentState {
        
        var groupingPlaylists: [String: GroupingPlaylistPersistentState] = [:]
        
        for (type, playlist) in self.groupingPlaylists {
            groupingPlaylists[type.rawValue] = (playlist as! GroupingPlaylist).persistentState
        }
        
        return PlaylistPersistentState(tracks: self.tracks.map {$0.file.path},
                                       groupingPlaylists: groupingPlaylists)
    }
}
