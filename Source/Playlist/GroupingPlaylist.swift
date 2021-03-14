import Foundation

/*
    A grouping playlist is a hierarchical playlist in which tracks are categorized, into groups, by a certain criterion, for example - artist/album/genre.
 
    Each such category of tracks that have matching criteria (for ex, all have the same artist) is a "group". In such a playlist, groups are the top-level items, and tracks are children of the groups.
 
    The groups are ordered and have indexes ("group index"), and the tracks under each group are also ordered and have indexes ("track index") relative to their parent group.
 
    The playlist's hierarchy looks like the following:
 
    Group 0
        -> Track 0
        -> Track 1
        -> Track 2
 
    Group 1
        -> Track 0
        -> Track 1
 
    Group 2
        -> Track 0
        -> Track 1
 */
class GroupingPlaylist: GroupingPlaylistCRUDProtocol {
    
    // The type of the playlist describes the criterion used to categorize the tracks within it (for ex, "artists")
    let playlistType: PlaylistType
    
    // The type of each group within this playlist (for ex, "artist")
    let typeOfGroups: GroupType
    
    // All groups in this playlist
    var groups: [Group] = []
    
    // Mappings of groups by name, for quick and convenient searching of groups. GroupName -> Group
    private var groupsByName: [String: Group] = [String: Group]()
    
    init(_ type: PlaylistType) {
        
        self.playlistType = type
        self.typeOfGroups = type.toGroupType()!
    }
    
    // MARK: Accessor functions
   
    var numberOfGroups: Int {groups.count}
    
    func groupAtIndex(_ index: Int) -> Group? {
        return groups.itemAtIndex(index)
    }
    
    // Assumes group exists in groups array
    func indexOfGroup(_ group: Group) -> Int? {
        return groups.firstIndex(of: group)
    }
    
    func groupingInfoForTrack(_ track: Track) -> GroupedTrack? {
        
        if let group = getGroupForTrack(track), let groupIndex = indexOfGroup(group), let trackIndex = group.indexOfTrack(track) {
            return GroupedTrack(track, group, trackIndex, groupIndex)
        }
        
        return nil
    }
    
    // Track may or may not already exist in playlist
    private func getGroupNameForTrack(_ track: Track) -> String {
        
        switch self.typeOfGroups {
            
        case .artist: return track.artist ?? "<Unknown>"
            
        case .album: return track.album ?? "<Unknown>"
            
        case .genre: return track.genre ?? "<Unknown>"
            
        }
    }
    
    private func getGroupForTrack(_ track: Track) -> Group? {
        return groupsByName[getGroupNameForTrack(track)]
    }
    
    private func createGroupForTrack(_ track: Track) -> (group: Group, groupIndex: Int) {
        
        let groupName = getGroupNameForTrack(track)
        let newGroup = Group(self.typeOfGroups, groupName)
        groupsByName[groupName] = newGroup
        let groupIndex = groups.addItem(newGroup)
        
        return (newGroup, groupIndex)
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        return self.typeOfGroups == .genre ? track.displayName : (track.title ?? track.defaultDisplayName)
    }
    
    func search(_ query: SearchQuery) -> SearchResults {
        
        // The name of the "search field" is simply the description of the group type, for ex - "artist"
        let searchField = typeOfGroups.rawValue
        
        // For all groups whose names match the query, collect all their child tracks
        let results: [SearchResult] = groups.filter{query.compare($0.name)}.flatMap {group in group.tracks.map
        {SearchResult(location: SearchResultLocation(trackIndex: nil, track: $0, groupInfo: nil), match: (searchField, group.name))}}
        
        return SearchResults(results)
    }
    
    // MARK: Mutator functions
    
    func addTrack(_ track: Track) -> GroupedTrackAddResult {
        
        // Determine the group this track belongs in (the group may not already exist)
        if let group = getGroupForTrack(track) {
            return GroupedTrackAddResult(track: GroupedTrack(track, group, group.addTrack(track), groups.firstIndex(of: group)!), groupCreated: false)
        }
        
        // Group doesn't exist, create it.
        let newGroupAndIndex = createGroupForTrack(track)
        let newGroup = newGroupAndIndex.group
        
        return GroupedTrackAddResult(track: GroupedTrack(track, newGroup, newGroup.addTrack(track), newGroupAndIndex.groupIndex), groupCreated: true)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ removedGroups: [Group]) -> [GroupedItemRemovalResult] {
        
        var groupsToRemove = removedGroups
        var tracksByGroup: [Group: [Track]] = tracks.categorizeBy({getGroupForTrack($0)!}).filter({!groupsToRemove.contains($0.key)})
        
        // If all tracks in a group were removed, just remove the group instead of its individual tracks.
        tracksByGroup.filter({$0.size == $1.count}).forEach({
            
            groupsToRemove.append($0.key)
            tracksByGroup.removeValue(forKey: $0.key)
        })
        
        // Sort group removals by group index (descending), and remove groups
        let groupRemovedResults = groupsToRemove.map {GroupRemovalResult($0, indexOfGroup($0)!)}
            .sorted(by: GroupRemovalResult.compareDescending)
        
        groupRemovedResults.forEach({removeGroupAtIndex($0.groupIndex)})
        
        // Remove tracks from their respective parent groups and note the track indexes (this does not have to be done in the order of group index)
        let trackRemovedResults: [GroupedTracksRemovalResult] = tracksByGroup.map {GroupedTracksRemovalResult($0, indexOfGroup($0)!, removeTracksFromGroup($1, $0))}
        
        return (groupRemovedResults + trackRemovedResults)
    }
    
    private func removeGroupAtIndex(_ index: Int) {
        
        if let group = groups.removeItem(index) {
            groupsByName.removeValue(forKey: group.name)
        }
    }
    
    private func removeTracksFromGroup(_ removedTracks: [Track], _ group: Group) -> IndexSet {
        return group.removeTracks(removedTracks)
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsUp(groupsToMove) :
            doMoveTracks(tracks, {group, tracks in group.moveTracksUp(tracks)})
    }
    
    private func moveGroupsUp(_ groupsToMove: [Group]) -> ItemMoveResults {
        return ItemMoveResults(groups.moveItemsUp(groupsToMove).map {GroupMoveResult($0.key, $0.value)}, playlistType)
    }
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsToTop(groupsToMove) :
            doMoveTracks(tracks, {group, tracks in group.moveTracksToTop(tracks)})
    }
    
    private func moveGroupsToTop(_ groupsToMove: [Group]) -> ItemMoveResults {
        return ItemMoveResults(groups.moveItemsToTop(groupsToMove).map {GroupMoveResult($0.key, $0.value)}, playlistType)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsDown(groupsToMove) :
            doMoveTracks(tracks, {group, tracks in group.moveTracksDown(tracks)})
    }
    
    private func moveGroupsDown(_ groupsToMove: [Group]) -> ItemMoveResults {
        return ItemMoveResults(groups.moveItemsDown(groupsToMove).map {GroupMoveResult($0.key, $0.value)}, playlistType)
    }
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsToBottom(groupsToMove) :
            doMoveTracks(tracks, {group, tracks in group.moveTracksToBottom(tracks)})
    }

    private func moveGroupsToBottom(_ groupsToMove: [Group]) -> ItemMoveResults {
        return ItemMoveResults(groups.moveItemsToBottom(groupsToMove).map {GroupMoveResult($0.key, $0.value)}, playlistType)
    }
    
    // Move tracks within a group
    private func doMoveTracks(_ tracks: [Track], _ moveOperation: (Group, [Track]) -> [Int: Int]) -> ItemMoveResults {
        
        // Find out which group(s) these tracks belong to
        let parentGroups: Set<Group> = Set(tracks.compactMap {getGroupForTrack($0)})
        
        // Cannot move tracks from multiple groups
        guard parentGroups.count == 1, let group = parentGroups.first else {
            return ItemMoveResults([], playlistType)
        }
        
        return ItemMoveResults(moveOperation(group, tracks).map {TrackMoveResult($0.key, $0.value, group)}, playlistType)
    }
    
    // MARK: Drag 'n drop ---------------------------------------------------------------------------------------------------
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        if groups.isNonEmpty {
            
            let sourceIndices = IndexSet(groups.compactMap {indexOfGroup($0)})
            let results: [ItemMoveResult] = self.groups.dragAndDropItems(sourceIndices, dropIndex).map {GroupMoveResult($0.key, $0.value)}
            
            return ItemMoveResults(results, playlistType)
            
        } else if let theDropParent = dropParent {
            
            let sourceIndices = IndexSet(tracks.compactMap {theDropParent.indexOfTrack($0)})
            let results: [ItemMoveResult] = theDropParent.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value, theDropParent)}
            
            return ItemMoveResults(results, playlistType)
        }
        
        return ItemMoveResults([], playlistType)
    }
    
    func sort(_ sort: Sort) {
        
        let comparator = SortComparator(sort, self.displayNameForTrack)
        
        // Sorts groups, and if requested, also the child tracks within each group
        if sort.groupsSort != nil {
            groups.sort(by: comparator.compareGroups)
        }

        // Sorts all tracks within each given parent group
        if let tracksSort = sort.tracksSort {
            
            let parentGroups = tracksSort.scope == .allGroups ? self.groups : tracksSort.parentGroups
            parentGroups.forEach({$0.sort(comparator.compareTracks)})
        }
    }
    
    func clear() {
        
        groups.removeAll()
        groupsByName.removeAll()
    }
}
