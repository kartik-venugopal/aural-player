import Foundation

/*
    A grouping playlist is a hierarchical playlist in which tracks are categorized by a certain criterion, for example - artist/album/genre.
 
    Each such category of tracks that have matching criteria (for ex, all have the same artist) is a "group". In such a playlist, groups are the top-level items, and tracks are children of the groups.
 
    The groups are ordered and have indexes ("group index"), and the tracks under each group are also ordered and have indexes ("track index") relative to their parent group.
 
    The hierarchy structure looks like the following:
 
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
        
        var groupName: String?
        
        switch self.typeOfGroups {
            
        case .artist: groupName = track.groupingInfo.artist
            
        case .album: groupName = track.groupingInfo.album
            
        case .genre: groupName = track.groupingInfo.genre
            
        }
        
        return groupName ?? "<Unknown>"
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
        return self.typeOfGroups == .genre ? track.conciseDisplayName : (track.displayInfo.title ?? track.conciseDisplayName)
    }
    
    func search(_ query: SearchQuery) -> SearchResults {
        
        var results: [SearchResult] = [SearchResult]()
        
        // The name of the "search field" is simply the description of the group type, for ex - "artist"
        let searchField = typeOfGroups.rawValue
        
        // Return all tracks whose group name matches the search text
        for group in groups {
            
            if (compare(group.name, query)) {
                
                for track in group.allTracks() {
                    
                    // Location info does not need to be computed here
                    results.append(SearchResult(location: SearchResultLocation(trackIndex: nil, track: track, groupInfo: nil), match: (searchField, group.name)))
                }
            }
        }
        
        return SearchResults(results)
    }
    
    // Helper function that compares the value of a single field to the search text to determine if there is a match
    private func compare(_ fieldVal: String, _ query: SearchQuery) -> Bool {
        
        let caseSensitive: Bool = query.options.caseSensitive
        let queryText: String = caseSensitive ? query.text : query.text.lowercased()
        let compared: String = caseSensitive ? fieldVal : fieldVal.lowercased()
        let type: SearchType = query.type
        
        switch type {
            
        case .beginsWith: return compared.hasPrefix(queryText)
            
        case .endsWith: return compared.hasSuffix(queryText)
            
        case .equals: return compared == queryText
            
        case .contains: return compared.contains(queryText)
            
        }
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
    
    func removeTracksAndGroups(_ tracks: [Track], _ removedGroups: [Group]) -> [ItemRemovalResult] {
        
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
        let trackRemovedResults: [GroupedTracksRemovalResult] = tracksByGroup.map {GroupedTracksRemovalResult(removeTracksFromGroup($1, $0), $0, indexOfGroup($0)!)}
        
        // Gather all results, and sort by group index (descending)
        return (groupRemovedResults + trackRemovedResults).sorted(by: ItemRemovalResultComparators.compareDescending)
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
            doMoveTracks(tracks, { group, tracks in group.moveTracksUp(tracks)}, true)
    }
    
    private func moveGroupsUp(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        // 1 - Move groups up
        // 2 - Sort the [srcIndex: destIndex] results in ascending order by srcIndex
        // 3 - Map the results to an array of GroupMoveResult
        let results: [GroupMoveResult] = groups.moveItemsUp(groupsToMove).map {GroupMoveResult($0.key, $0.value)}.sorted(by: GroupMoveResult.compareAscending)
        
        // Ascending order (by old index)
        return ItemMoveResults(results, playlistType)
    }
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsToTop(groupsToMove) :
            doMoveTracks(tracks, { group, tracks in group.moveTracksToTop(tracks)}, true)
    }
    
    private func moveGroupsToTop(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        // 1 - Move groups to top
        // 2 - Sort the [srcIndex: destIndex] results in ascending order by srcIndex
        // 3 - Map the results to an array of GroupMoveResult
        let results: [GroupMoveResult] = groups.moveItemsToTop(groupsToMove).map {GroupMoveResult($0.key, $0.value)}.sorted(by: GroupMoveResult.compareAscending)
        
        // Ascending order (by old index)
        return ItemMoveResults(results, playlistType)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsDown(groupsToMove) :
            doMoveTracks(tracks, { group, tracks in group.moveTracksDown(tracks)}, false)
    }
    
    private func moveGroupsDown(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        // 1 - Move groups up
        // 2 - Sort the [srcIndex: destIndex] results in descending order by srcIndex
        // 3 - Map the results to an array of GroupMoveResult
        let results: [GroupMoveResult] = groups.moveItemsDown(groupsToMove).map {GroupMoveResult($0.key, $0.value)}.sorted(by: GroupMoveResult.compareDescending)
        
        // Descending order (by old index)
        return ItemMoveResults(results, playlistType)
    }
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        return groupsToMove.isNonEmpty ?
            moveGroupsToBottom(groupsToMove) :
            doMoveTracks(tracks, { group, tracks in group.moveTracksToBottom(tracks)}, false)
    }

    // Move tracks within a group
    private func doMoveTracks(_ tracks: [Track], _ moveOperation: (Group, [Track]) -> [Int: Int], _ sortAscending: Bool) -> ItemMoveResults {
        
        // Find out which group(s) these tracks belong to
        let parentGroups: Set<Group> = Set(tracks.compactMap {getGroupForTrack($0)})
        
        // Cannot move tracks from multiple groups
        guard parentGroups.count == 1, let group = parentGroups.first else {
            return ItemMoveResults([], playlistType)
        }
        
        let results: [TrackMoveResult] = moveOperation(group, tracks).map {TrackMoveResult($0.key, $0.value, group)}
            .sorted(by: sortAscending ? TrackMoveResult.compareAscending : TrackMoveResult.compareDescending)
        
        return ItemMoveResults(results, playlistType)
    }
    
    private func moveGroupsToBottom(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        // 1 - Move groups
        // 2 - Sort the [srcIndex: destIndex] results in descending order by srcIndex
        // 3 - Map the results to an array of GroupMoveResult
        let results: [GroupMoveResult] = groups.moveItemsToBottom(groupsToMove).map {GroupMoveResult($0.key, $0.value)}.sorted(by: GroupMoveResult.compareDescending)
        
        // Descending order (by old index)
        return ItemMoveResults(results, playlistType)
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        let movingGroups = !groups.isEmpty
        
        // Get child indexes of tracks/groups
        let childIndexes = getChildIndexes(tracks, groups, dropParent, movingGroups)
        
        // Calculate destination
        let destination = calculateReorderingDestination(childIndexes, dropIndex)
        
        // Reorder
        return performReordering(movingGroups, childIndexes, dropParent, dropIndex, destination)
    }
    
    // For tracks and groups, get their child indexes within their parents
    private func getChildIndexes(_ tracks: [Track], _ groups: [Group], _ dropParent: Group?, _ movingGroups: Bool) -> IndexSet {
        
        var childIndexes: [Int] = []
        
        if movingGroups {
            childIndexes = groups.compactMap {indexOfGroup($0)}
            
        } else if let theDropParent = dropParent {
            childIndexes = tracks.compactMap {theDropParent.indexOfTrack($0)}
        }
        
        return IndexSet(childIndexes)
    }
    
    /*
     In response to a playlist reordering by drag and drop, and given source indexes, a destination index, and the drop operation (on/above), determines which indexes the source rows will occupy.
     */
    private func calculateReorderingDestination(_ sourceIndexSet: IndexSet, _ dropIndex: Int) -> IndexSet {
        
        // Find out how many source items are above the dropRow and how many below
        let sourceIndexesAboveDropIndex = sourceIndexSet.count(in: 0..<dropIndex)
        let sourceIndexesBelowDropIndex = sourceIndexSet.count - sourceIndexesAboveDropIndex
        
        // All source items above the dropRow will form a contiguous block ending at the dropRow
        // All source items below the dropRow will form a contiguous block starting one row below the dropRow and extending below it
        
        // The lowest index in the destination rows
        let minDestinationIndex = dropIndex - sourceIndexesAboveDropIndex
        
        // The highest index in the destination rows
        let maxDestinationIndex = dropIndex + sourceIndexesBelowDropIndex - 1
        
        return IndexSet(minDestinationIndex...maxDestinationIndex)
    }
    
    private func performReordering(_ movingGroups: Bool, _ childIndexes: IndexSet, _ dropParent: Group?, _ dropRow: Int, _ destination: IndexSet) -> ItemMoveResults {
        
        if (movingGroups) {
            return reorderGroups(childIndexes, dropRow, destination)
        } else {
            // Reordering tracks
            return reorderTracks(childIndexes, dropParent!, dropRow, destination)
        }
    }
    
    private func reorderTracks(_ sourceIndexSet: IndexSet, _ parentGroup: Group, _ dropRow: Int, _ destination: IndexSet) -> ItemMoveResults {
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var results = [ItemMoveResult]()
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Track]()
        var sourceIndexMappings = [Track: Int]()
        
        // Make sure that the source indexes are iterated in descending order. This will be important in Step 2.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            if let track = parentGroup.removeTrackAtIndex($0) {
                sourceItems.append(track)
                sourceIndexMappings[track] = $0
            }
        })
        
        // Step 2 - Copy over the source items into the destination holes
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationIndexes = destination.sorted(by: {x, y -> Bool in x < y})
        
        sourceItems = sourceItems.reversed()
        
        destinationIndexes.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let track = sourceItems[cursor]
            parentGroup.insertTrackAtIndex(track, $0)
            
            let srcIndex = sourceIndexMappings[track]!
            results.append(TrackMoveResult(srcIndex, $0, parentGroup))
            
            cursor += 1
        })
        
        return ItemMoveResults(results, self.typeOfGroups.toPlaylistType())
    }
    
    private func reorderGroups(_ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: IndexSet) -> ItemMoveResults {
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var results = [ItemMoveResult]()
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Group]()
        var sourceIndexMappings = [Group: Int]()
        
        // Make sure they the source indexes are iterated in descending order. This will be important in Step 2.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            let group = groups.remove(at: $0)
            sourceItems.append(group)
            sourceIndexMappings[group] = $0
        })
        
        // Step 2 - Copy over the source items into the destination holes
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationIndexes = destination.sorted(by: {x, y -> Bool in x < y})
        
        sourceItems = sourceItems.reversed()
        
        destinationIndexes.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let group = sourceItems[cursor]
            groups.insert(group, at: $0)
            
            let srcIndex = sourceIndexMappings[group]!
            results.append(GroupMoveResult(srcIndex, $0))
            
            cursor += 1
        })
        
        return ItemMoveResults(results, self.typeOfGroups.toPlaylistType())
    }
    
    func sort(_ sort: Sort) {
        
        let comparator = SortComparator(sort, self.displayNameForTrack)
        
        // Sorts groups, and if requested, also the child tracks within each group
        if sort.groupsSort != nil {
            groups.sort(by: comparator.compareGroups)
        }
        
        if let tracksSort = sort.tracksSort {
            
            if tracksSort.scope == .allGroups {
                sortTracksInGroups(self.groups, comparator.compareTracks)
            } else {
                // Selected groups
                sortTracksInGroups(tracksSort.parentGroups!, comparator.compareTracks)
            }
        }
    }
    
    // Sorts all tracks within each given parent group, with the specified track comparison strategy
    private func sortTracksInGroups(_ parentGroups: [Group], _ trackComparisonStrategy: (Track, Track) -> Bool) {
        parentGroups.forEach({$0.sort(trackComparisonStrategy)})
    }
    
    private func compareTracks_ascendingByDisplayName(aTrack: Track, anotherTrack: Track) -> Bool {
        return displayNameForTrack(aTrack).compare(displayNameForTrack(anotherTrack)) == ComparisonResult.orderedAscending
    }
    
    private func compareTracks_descendingByDisplayName(aTrack: Track, anotherTrack: Track) -> Bool {
        return displayNameForTrack(aTrack).compare(displayNameForTrack(anotherTrack)) == ComparisonResult.orderedDescending
    }
    
    func clear() {
        groups.removeAll()
        groupsByName.removeAll()
    }
}
