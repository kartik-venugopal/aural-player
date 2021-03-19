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
    private var groups: [Group] = [Group]()
    
    // Mappings of groups by name, for quick and convenient searching of groups. GroupName -> Group
    private var groupsByName: [String: Group] = [String: Group]()
    
//    private let trackAddQueue = DispatchQueue(label: "threadSafeGroupsArray", attributes: .concurrent)
    
    private var opsAdded: Int = 0
    private var opsFinished: Int = 0
    
    init(_ type: PlaylistType, _ groupType: GroupType) {
        
        self.playlistType = type
        self.typeOfGroups = groupType
    }
    
    // MARK: Accessor functions
   
    var numberOfGroups: Int {return groups.count}
    
    func groupAtIndex(_ index: Int) -> Group {
        return groups[index]
    }
    
    // Assumes group exists in groups array
    func indexOfGroup(_ group: Group) -> Int {
        return groups.firstIndex(of: group)!
    }
    
    func groupingInfoForTrack(_ track: Track) -> GroupedTrack? {
        
        if let group = getGroupForTrack(track) {
            
            let groupIndex = indexOfGroup(group)
            
            // Track may not have been added to group yet, or track may have been removed from playlist
            if let trackIndex = group.indexOfTrack(track) {
                return GroupedTrack(track, group, trackIndex, groupIndex)
            }
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
    
    // Assumes track already exists in playlist, i.e. return value cannot be nil
    private func getGroupForTrack(_ track: Track) -> Group? {
        
        let name = getGroupNameForTrack(track)
        return groupsByName[name]
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        
        switch self.typeOfGroups {
            
        case .artist:
            
            return track.displayInfo.title ?? track.conciseDisplayName
            
        case .album:
            
            return track.displayInfo.title ?? track.conciseDisplayName
            
        case .genre:
            
            return track.conciseDisplayName
        }
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
        
        // Determine the name of the group this track belongs in (the group may not already exist)
        let groupName = getGroupNameForTrack(track)
        
        // Information that will form the result that is returned
        var group: Group?
        var groupCreated: Bool = false
        var groupIndex: Int = -1
        
        //        trackAddQueue.async(flags: .barrier) {
        
        group = self.groupsByName[groupName]
        
        if (group == nil) {
            
            // Group doesn't already exist, create it
            
            group = Group(self.typeOfGroups, groupName)
            self.groups.append(group!)
            
            self.groupsByName[groupName] = group
            groupIndex = self.groups.count - 1
            
            groupCreated = true
            
        } else {
            
            // Group exists, get its index
            groupIndex = self.groups.firstIndex(of: group!)!
        }
            
            // Add the track to the group
        let trackIndex: Int = group!.addTrack(track)
        let groupedTrack = GroupedTrack(track, group!, trackIndex, groupIndex)
            
            // UI notification
//            DispatchQueue.main.async {
//                SyncMessenger.publishNotification(TrackGroupedNotification(groupedTrack!, groupCreated))
//            }
        
        return GroupedTrackAddResult(track: groupedTrack, groupCreated: groupCreated)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ removedGroups: [Group]) -> [ItemRemovalResult] {
        
        var tracksByGroup: [Group: [Track]] = [Group: [Track]]()
        var _groups = removedGroups
        
        // Categorize tracks by group
        for track in tracks {
            
            let group = getGroupForTrack(track)!
            
            // Ignore tracks whose parent groups are being removed
            if (!_groups.contains(group)) {
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Track]()
                }
                
                tracksByGroup[group]!.append(track)
            }
        }
        
        // Further simplification
        for (group, tracks) in tracksByGroup {
            
            // If all tracks in group were removed, just remove the group instead
            if (tracks.count == group.size()) {
                _groups.append(group)
            }
        }
        
        // If a group is being removed, ignore its tracks
        _groups.forEach({tracksByGroup.removeValue(forKey: $0)})
        
        var groupRemovedResults = [GroupRemovalResult]()
        var trackRemovedResults = [GroupedTracksRemovalResult]()
        
        // Gather group removals with group indexes
        _groups.forEach({groupRemovedResults.append(GroupRemovalResult($0, indexOfGroup($0)))})
        
        // Remove tracks from their respective parent groups and note the track indexes (this does not have to be done in the order of group index)
        tracksByGroup.forEach({
            
            let group = $0.key
            let tracks = $0.value
            
            let trackIndexes = removeTracksFromGroup(tracks, group)
            trackRemovedResults.append(GroupedTracksRemovalResult(trackIndexes, group, indexOfGroup(group)))
        })
        
        // Sort group removals by group index (descending), and remove groups
        groupRemovedResults = groupRemovedResults.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex})
        groupRemovedResults.forEach({removeGroupAtIndex($0.groupIndex)})
        
        // Gather all results
        var allResults = [ItemRemovalResult]()
        groupRemovedResults.forEach({allResults.append($0)})
        trackRemovedResults.forEach({allResults.append($0)})
        
        // Sort by group index (descending)
        return allResults.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex})
    }
    
    private func removeGroupAtIndex(_ index: Int) {
        let group = groups.remove(at: index)
        groupsByName.removeValue(forKey: group.name)
    }
    
    private func removeTracksFromGroup(_ removedTracks: [Track], _ group: Group) -> IndexSet {
        
        var trackIndexes = [Int]()
        
        // Collect the indexes of each track within the parent group
        removedTracks.forEach({trackIndexes.append(group.indexOfTrack($0)!)})
        
        // Sort the indexes in descending order
        trackIndexes = trackIndexes.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        
        // Remove the tracks from the group
        trackIndexes.forEach({_ = group.removeTrackAtIndex($0)})
        
        return IndexSet(trackIndexes)
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        if (!groupsToMove.isEmpty) {
            
            return moveGroupsUp(groupsToMove)
            
        } else {
            
            // Find out which group these tracks belong to, and categorize them
            var tracksByGroup: [Group: [Int]] = [Group: [Int]]()
            var results = [ItemMoveResult]()
            
            // Categorize tracks by group
            for track in tracks {
                
                let group = getGroupForTrack(track)!
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Int]()
                }
                
                tracksByGroup[group]!.append(group.indexOfTrack(track)!)
            }
            
            // Cannot move tracks from different groups
            if (tracksByGroup.keys.count > 1) {
                return ItemMoveResults([], playlistType)
            }

            tracksByGroup.forEach({
                
                let group = $0.key
                let tracks = $0.value
                
                let mappings = group.moveTracksUp(IndexSet(tracks))
                for (old, new) in mappings {
                     results.append(TrackMoveResult(old, new, group))
                }
            })
            
            // Ascending order (by old index)
            return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), playlistType)
        }
    }
    
    private func moveGroupsUp(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        var indexes = [Int]()
        groupsToMove.forEach({indexes.append(indexOfGroup($0))})
        
        // Indexes need to be in ascending order, because groups need to be moved up, one by one, from top to bottom of the playlist
        let ascendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMoveResult]()
        
        // Determine if there is a contiguous block of groups at the top of the playlist, that cannot be moved. If there is, determine its size. At the end of the loop, the cursor's value will equal the size of the block.
        var unmovableBlockCursor = 0
        while (ascendingOldIndexes.contains(unmovableBlockCursor)) {
            unmovableBlockCursor += 1
        }
        
        // If there are any groups that can be moved, move them and store the index mappings
        if (unmovableBlockCursor < ascendingOldIndexes.count) {
            
            for index in unmovableBlockCursor...ascendingOldIndexes.count - 1 {
                
                let oldIndex = ascendingOldIndexes[index]
                let newIndex = moveGroupUp(oldIndex)
                results.append(GroupMoveResult(oldIndex, newIndex))
            }
        }
        
        // Ascending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), self.typeOfGroups.toPlaylistType())
    }
    
    private func moveGroupUp(_ index: Int) -> Int {
        
        let upIndex = index - 1
        swapGroups(index, upIndex)
        return upIndex
    }
    
    private func swapGroups(_ index1: Int, _ index2: Int) {
        
        let temp = groups[index1]
        groups[index1] = groups[index2]
        groups[index2] = temp
    }
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        if (!groupsToMove.isEmpty) {
            
            return moveGroupsToTop(groupsToMove)
            
        } else {
            
            // Find out which group these tracks belong to, and categorize them
            var tracksByGroup: [Group: [Int]] = [Group: [Int]]()
            var results = [ItemMoveResult]()
            
            // Categorize tracks by group
            for track in tracks {
                
                let group = getGroupForTrack(track)!
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Int]()
                }
                
                tracksByGroup[group]!.append(group.indexOfTrack(track)!)
            }
            
            // Cannot move tracks from different groups
            if (tracksByGroup.keys.count > 1) {
                return ItemMoveResults([], playlistType)
            }
            
            tracksByGroup.forEach({
                
                let group = $0.key
                let tracks = $0.value
                
                let mappings = group.moveTracksToTop(IndexSet(tracks))
                for (old, new) in mappings {
                    results.append(TrackMoveResult(old, new, group))
                }
            })
            
            // Ascending order (by old index)
            return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), playlistType)
        }
    }
    
    private func moveGroupsToTop(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        var groupsMoved: Int = 0
        
        var groupIndexes: [Int] = []
        groupsToMove.forEach({groupIndexes.append(indexOfGroup($0))})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMoveResult]()
        
        let sortedGroups = groupIndexes.sorted(by: {x, y -> Bool in x < y})

        for index in sortedGroups {

            // Remove from original location and insert at top, one after another, below the previous one
            let group = groups.remove(at: index)
            groups.insert(group, at: groupsMoved)
            
            results.append(GroupMoveResult(index, groupsMoved))

            groupsMoved += 1
        }
        
        // Ascending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), self.typeOfGroups.toPlaylistType())
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        if (!groupsToMove.isEmpty) {
            
            return moveGroupsDown(groupsToMove)
            
        } else {
            
            // Find out which group these tracks belong to, and categorize them
            var tracksByGroup: [Group: [Int]] = [Group: [Int]]()
            var results = [ItemMoveResult]()
            
            // Categorize tracks by group
            for track in tracks {
                
                let group = getGroupForTrack(track)!
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Int]()
                }
                
                tracksByGroup[group]!.append(group.indexOfTrack(track)!)
            }
            
            // Cannot move tracks from different groups
            if (tracksByGroup.keys.count > 1) {
                return ItemMoveResults([], playlistType)
            }
            
            tracksByGroup.forEach({
                
                let group = $0.key
                let tracks = $0.value
                
                let mappings = group.moveTracksDown(IndexSet(tracks))
                for (old, new) in mappings {
                    results.append(TrackMoveResult(old, new, group))
                }
            })
            
            // Descending order (by old index)
            return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), playlistType)
        }
    }
    
    private func moveGroupsDown(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        var indexes = [Int]()
        groupsToMove.forEach({indexes.append(indexOfGroup($0))})
        
        // Indexes need to be in descending order, because groups need to be moved down, one by one, from bottom to top of the playlist
        let descendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMoveResult]()
        
        // Determine if there is a contiguous block of groups at the top of the playlist, that cannot be moved. If there is, determine its size.
        var unmovableBlockCursor = groups.count - 1
        
        // Tracks the size of the unmovable block. At the end of the loop, the variable's value will equal the size of the block.
        var unmovableBlockSize = 0
        
        while (descendingOldIndexes.contains(unmovableBlockCursor)) {
            
            // Since this group cannot be moved, map its old index to the same old index
            unmovableBlockCursor -= 1
            unmovableBlockSize += 1
        }
        
        // If there are any groups that can be moved, move them and store the index mappings
        if (unmovableBlockSize < descendingOldIndexes.count) {
            
            for index in unmovableBlockSize...descendingOldIndexes.count - 1 {
                
                let oldIndex = descendingOldIndexes[index]
                let newIndex = moveGroupDown(oldIndex)
                results.append(GroupMoveResult(oldIndex, newIndex))
            }
        }
        
        // Descending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), playlistType)
    }
    
    private func moveGroupDown(_ index: Int) -> Int {
        
        let downIndex = index + 1
        swapGroups(index, downIndex)
        return downIndex
    }
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMoveResults {
        
        if (!groupsToMove.isEmpty) {
            
            return moveGroupsToBottom(groupsToMove)
            
        } else {
            
            // Find out which group these tracks belong to, and categorize them
            var tracksByGroup: [Group: [Int]] = [Group: [Int]]()
            var results = [ItemMoveResult]()
            
            // Categorize tracks by group
            for track in tracks {
                
                let group = getGroupForTrack(track)!
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Int]()
                }
                
                tracksByGroup[group]!.append(group.indexOfTrack(track)!)
            }
            
            // Cannot move tracks from different groups
            if (tracksByGroup.keys.count > 1) {
                return ItemMoveResults([], playlistType)
            }
            
            tracksByGroup.forEach({
                
                let group = $0.key
                let tracks = $0.value
                
                let mappings = group.moveTracksToBottom(IndexSet(tracks))
                for (old, new) in mappings {
                    results.append(TrackMoveResult(old, new, group))
                }
            })
            
            // Descending order (by old index)
            return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), playlistType)
        }
    }
    
    private func moveGroupsToBottom(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        var groupsMoved: Int = 0
        
        var groupIndexes: [Int] = []
        groupsToMove.forEach({groupIndexes.append(indexOfGroup($0))})
        
        let sortedGroups = groupIndexes.sorted(by: {x, y -> Bool in x > y})
        var results = [ItemMoveResult]()
        
        for index in sortedGroups {
            
            let group = groups.remove(at: index)
            let newIndex = groups.endIndex - groupsMoved
            groups.insert(group, at: newIndex)
            
            results.append(GroupMoveResult(index, newIndex))
            
            groupsMoved += 1
        }
        
        // Descending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), playlistType)
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
        
        var childIndexes = [Int]()
        
        if (movingGroups) {
            groups.forEach({childIndexes.append(indexOfGroup($0))})
        } else {
            tracks.forEach({childIndexes.append(dropParent!.indexOfTrack($0)!)})
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
        
        // Make sure they the source indexes are iterated in descending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            let track = parentGroup.removeTrackAtIndex($0)
            sourceItems.append(track)
            sourceIndexMappings[track] = $0
        })
        
        // Step 4 - Copy over the source items into the destination holes
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
        
        // Make sure they the source indexes are iterated in descending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            let group = groups.remove(at: $0)
            sourceItems.append(group)
            sourceIndexMappings[group] = $0
        })
        
        // Step 4 - Copy over the source items into the destination holes
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
