import Foundation

class GroupingPlaylist: GroupingPlaylistCRUDProtocol {
    
    private var type: GroupType
    private var groups: [Group] = [Group]()
    private var groupsByName: [String: Group] = [String: Group]()
    
    init(_ type: GroupType) {
        self.type = type
    }
    
    func groupType() -> GroupType {
        return type
    }
    
    func numberOfGroups() -> Int {
        return groups.count
    }
    
    func clear() {
        groups.removeAll()
        groupsByName.removeAll()
    }
    
    func search(_ query: SearchQuery) -> SearchResults {
        
        var results: [SearchResult] = [SearchResult]()
        
        // Return all tracks whose group name matches the text
        for group in groups {
            
            if (compare(group.name, query)) {
                
                for track in group.allTracks() {
                    
                    results.append(SearchResult(location: SearchResultLocation(trackIndex: nil, track: track, groupInfo: nil), match: (getSearchFieldName(), group.name)))
                }
            }
        }
        
        return SearchResults(results)
    }
    
    private func getSearchFieldName() -> String {
        return type.rawValue
    }
    
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
    
    func sort(_ sort: Sort) {
        
        switch sort.field {
            
        // Sort by name
        case .name:
            
            if sort.order == SortOrder.ascending {
                
                groups.sort(by: Sorts.compareGroups_ascendingByName)
                if sort.options.sortTracksInGroups {
                    sortAllTracks(compareTracks_ascendingByDisplayName)
                }
                
            } else {
                
                groups.sort(by: Sorts.compareGroups_descendingByName)
                if sort.options.sortTracksInGroups {
                    sortAllTracks(compareTracks_descendingByDisplayName)
                }
            }
            
        // Sort by duration
        case .duration:
            
            if sort.order == SortOrder.ascending {
                
                groups.sort(by: Sorts.compareGroups_ascendingByDuration)
                if sort.options.sortTracksInGroups {
                    sortAllTracks(Sorts.compareTracks_ascendingByDuration)
                }
                
            } else {
                
                groups.sort(by: Sorts.compareGroups_descendingByDuration)
                if sort.options.sortTracksInGroups {
                    sortAllTracks(Sorts.compareTracks_descendingByDuration)
                }
            }
        }
    }
    
    private func sortAllTracks(_ strategy: (Track, Track) -> Bool) {
        groups.forEach({$0.sort(strategy)})
    }
    
    private func compareTracks_ascendingByDisplayName(aTrack: Track, anotherTrack: Track) -> Bool {
        return displayNameForTrack(aTrack).compare(displayNameForTrack(anotherTrack)) == ComparisonResult.orderedAscending
    }
    
    private func compareTracks_descendingByDisplayName(aTrack: Track, anotherTrack: Track) -> Bool {
        return displayNameForTrack(aTrack).compare(displayNameForTrack(anotherTrack)) == ComparisonResult.orderedDescending
    }
    
    func addTrack(_ track: Track) -> GroupedTrackAddResult {
        
        let groupName = getGroupNameForTrack(track)
        
        var group: Group?
        var groupCreated: Bool = false
        var groupIndex: Int = -1
        
        ConcurrencyUtils.executeSynchronized(groups) {
        
            group = groupsByName[groupName]
            if (group == nil) {
                
                // Create the group
                group = Group(type, groupName)
                groups.append(group!)
                groupsByName[groupName] = group
                groupIndex = groups.count - 1
                
                groupCreated = true
                
            } else {
                groupIndex = groups.index(of: group!)!
            }
        }
        
        let trackIndex = group!.addTrack(track)
        let groupedTrack = GroupedTrack(track, group!, trackIndex, groupIndex)
        
        return GroupedTrackAddResult(track: groupedTrack, groupCreated: groupCreated)
    }
    
    // Track may or may not already exist in playlist
    private func getGroupNameForTrack(_ track: Track) -> String {
        
        var groupName: String?
        
        switch self.type {
            
        case .artist: groupName = track.groupingInfo.artist
            
        case .album: groupName = track.groupingInfo.album
            
        case .genre: groupName = track.groupingInfo.genre
            
        }
        
        return groupName ?? "<Unknown>"
    }
    
    // Assumes track already exists in playlist, i.e. return value cannot be nil
    private func getGroupForTrack(_ track: Track) -> Group {
        
        let name = getGroupNameForTrack(track)
        return groupsByName[name]!
    }
    
    // Returns group index
    private func removeGroup(_ group: Group) -> Int {
        
        if let index = groups.index(of: group) {
            
            groups.remove(at: index)
            groupsByName.removeValue(forKey: group.name)
            
            return index
        }
        
        return -1
    }
    
    func removeGroup(_ index: Int) {        
        let group = groups.remove(at: index)
        groupsByName.removeValue(forKey: group.name)
    }

    func groupAtIndex(_ index: Int) -> Group {
        return groups[index]
    }

    func size() -> Int {
        return groups.count
    }
    
    func indexOfTrack(_ track: Track) -> Int {
        return getGroupForTrack(track).indexOfTrack(track)!
    }
    
    func indexOfGroup(_ group: Group) -> Int {
        return groups.index(of: group)!
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        
        switch self.type {
            
        case .artist:
            
            return track.displayInfo.title ?? track.conciseDisplayName
            
        case .album:
            
            return track.displayInfo.title ?? track.conciseDisplayName
            
        case .genre:
            
            return track.conciseDisplayName
        }
    }
    
    private func removeTracksFromGroup(_ removedTracks: [Track], _ group: Group) -> IndexSet {
        
        var trackIndexes = [Int]()
        
        removedTracks.forEach({trackIndexes.append(group.indexOfTrack($0)!)})
        
        trackIndexes = trackIndexes.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        
        trackIndexes.forEach({_ = group.removeTrackAtIndex($0)})
        
        return IndexSet(trackIndexes)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ removedGroups: [Group]) -> [ItemRemovalResult] {
        
        var tracksByGroup: [Group: [Track]] = [Group: [Track]]()
        var _groups = removedGroups
        
        // Categorize tracks by group
        for track in tracks {
            
            let group = getGroupForTrack(track)
            
            // Ignore tracks whose groups are being removed
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
        _groups.forEach({
            tracksByGroup.removeValue(forKey: $0)})
        
        var groupRemovedResults = [GroupRemovalResult]()
        var trackRemovedResults = [GroupedTracksRemovalResult]()
        
        // Gather group removals with group indexes
        _groups.forEach({groupRemovedResults.append(GroupRemovalResult($0, indexOfGroup($0)))})
        
        // Remove tracks from their respective groups and note the track indexes (this does not have to be done in the order of group index)
        tracksByGroup.forEach({
            
            let group = $0.key
            let trackIndexes = removeTracksFromGroup($0.value, group)
            trackRemovedResults.append(GroupedTracksRemovalResult(trackIndexes, group, indexOfGroup(group)))
        })
        
        // Sort group removals by group index (descending), and remove groups
        groupRemovedResults = groupRemovedResults.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex})
        groupRemovedResults.forEach({removeGroup($0.groupIndex)})
        
        // Gather all results
        var allResults = [ItemRemovalResult]()
        groupRemovedResults.forEach({allResults.append($0)})
        trackRemovedResults.forEach({allResults.append($0)})
        
        // Sort by group index (descending)
        return allResults.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex})
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
                
                let group = getGroupForTrack(track)
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Int]()
                }
                
                tracksByGroup[group]!.append(group.indexOfTrack(track)!)
            }
            
            // Cannot move tracks from different groups
            if (tracksByGroup.keys.count > 1) {
                return ItemMoveResults([], self.type.toPlaylistType())
            }

            tracksByGroup.forEach({
                
                let group = $0.key
                let mappings = group.moveTracksUp(IndexSet($0.value))
                for (old, new) in mappings {
                     results.append(TrackMoveResult(old, new, group))
                }
            })
            
            // Ascending order (by old index)
            return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), self.type.toPlaylistType())
        }
    }
    
    private func moveGroupsUp(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        var indexes = [Int]()
        groupsToMove.forEach({indexes.append(indexOfGroup($0))})
        
        // Indexes need to be in ascending order, because tracks need to be moved up, one by one, from top to bottom of the playlist
        let ascendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMoveResult]()
        
        // Determine if there is a contiguous block of tracks at the top of the playlist, that cannot be moved. If there is, determine its size. At the end of the loop, the cursor's value will equal the size of the block.
        var unmovableBlockCursor = 0
        while (ascendingOldIndexes.contains(unmovableBlockCursor)) {
            unmovableBlockCursor += 1
        }
        
        // If there are any tracks that can be moved, move them and store the index mappings
        if (unmovableBlockCursor < ascendingOldIndexes.count) {
            
            for index in unmovableBlockCursor...ascendingOldIndexes.count - 1 {
                
                let oldIndex = ascendingOldIndexes[index]
                let newIndex = moveGroupUp(oldIndex)
                results.append(GroupMoveResult(oldIndex, newIndex))
            }
        }
        
        // Ascending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), self.type.toPlaylistType())
    }
    
    private func moveGroupUp(_ index: Int) -> Int {
        
        let upIndex = index - 1
        swapGroups(index, upIndex)
        return upIndex
    }
    
    private func swapGroups(_ index1: Int, _ index2: Int) {
        swap(&groups[index1], &groups[index2])
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
                
                let group = getGroupForTrack(track)
                
                if tracksByGroup[group] == nil {
                    tracksByGroup[group] = [Int]()
                }
                
                tracksByGroup[group]!.append(group.indexOfTrack(track)!)
            }
            
            // Cannot move tracks from different groups
            if (tracksByGroup.keys.count > 1) {
                return ItemMoveResults([], self.type.toPlaylistType())
            }
            
            tracksByGroup.forEach({
                
                let group = $0.key
                let mappings = group.moveTracksDown(IndexSet($0.value))
                for (old, new) in mappings {
                    results.append(TrackMoveResult(old, new, group))
                }
            })
            
            // Descending order (by old index)
            return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), self.type.toPlaylistType())
        }
    }
    
    private func moveGroupsDown(_ groupsToMove: [Group]) -> ItemMoveResults {
        
        var indexes = [Int]()
        groupsToMove.forEach({indexes.append(indexOfGroup($0))})
        
        // Indexes need to be in descending order, because tracks need to be moved down, one by one, from bottom to top of the playlist
        let descendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMoveResult]()
        
        // Determine if there is a contiguous block of tracks at the top of the playlist, that cannot be moved. If there is, determine its size.
        var unmovableBlockCursor = groups.count - 1
        
        // Tracks the size of the unmovable block. At the end of the loop, the variable's value will equal the size of the block.
        var unmovableBlockSize = 0
        
        while (descendingOldIndexes.contains(unmovableBlockCursor)) {
            
            // Since this track cannot be moved, map its old index to the same old index
            unmovableBlockCursor -= 1
            unmovableBlockSize += 1
        }
        
        // If there are any tracks that can be moved, move them and store the index mappings
        if (unmovableBlockSize < descendingOldIndexes.count) {
            
            for index in unmovableBlockSize...descendingOldIndexes.count - 1 {
                
                let oldIndex = descendingOldIndexes[index]
                let newIndex = moveGroupDown(oldIndex)
                results.append(GroupMoveResult(oldIndex, newIndex))
            }
        }
        
        // Descending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), self.type.toPlaylistType())
    }
    
    private func moveGroupDown(_ index: Int) -> Int {
        
        let downIndex = index + 1
        swapGroups(index, downIndex)
        return downIndex
    }
    
    func groupingInfoForTrack(_ track: Track) -> GroupedTrack {
        
        let group = getGroupForTrack(track)
        let groupIndex = indexOfGroup(group)
        let trackIndex = group.indexOfTrack(track)
        
        return GroupedTrack(track, group, trackIndex!, groupIndex)
    }
    
    func getGroupIndex(_ group: Group) -> Int {
        return groups.index(of: group)!
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
        
        return ItemMoveResults(results, self.type.toPlaylistType())
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
        
        return ItemMoveResults(results, self.type.toPlaylistType())
    }
}
