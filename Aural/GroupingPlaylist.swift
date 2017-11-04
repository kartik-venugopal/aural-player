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
                
                for track in group.tracks {
                    
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
        groups.forEach({
            $0.tracks.sort(by: strategy)
        })
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
    
    private func removeTrack(_ track: Track) -> Bool {
        
        var groupRemoved: Bool = false
        
        for group in groups {
            
            if let index = group.indexOfTrack(track) {
                
                ConcurrencyUtils.executeSynchronized(groups) {
                
                    group.removeTrackAtIndex(index)
                    
                    if (group.size() == 0) {
                        
                        let groupIndex = groups.index(of: group)!
                        groups.remove(at: groupIndex)
                        groupsByName.removeValue(forKey: group.name)
                        groupRemoved = true
                    }
                }
            }
        }
        
        return groupRemoved
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
        
        trackIndexes.forEach({group.removeTrackAtIndex($0)})
        
        return IndexSet(trackIndexes)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ removedGroups: [Group]) -> ItemRemovedResults {
        
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
        
        var groupRemovedResults = [GroupRemovedResult]()
        var trackRemovedResults = [TracksRemovedResult]()
        
        // Gather group removals with group indexes
        _groups.forEach({groupRemovedResults.append(GroupRemovedResult($0, indexOfGroup($0)))})
        
        // Remove tracks from their respective groups and note the track indexes (this does not have to be done in the order of group index)
        tracksByGroup.forEach({
            
            let group = $0.key
            let trackIndexes = removeTracksFromGroup($0.value, group)
            trackRemovedResults.append(TracksRemovedResult(trackIndexes, group, indexOfGroup(group)))
        })
        
        // Sort group removals by group index (descending), and remove groups
        groupRemovedResults = groupRemovedResults.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex})
        groupRemovedResults.forEach({removeGroup($0.groupIndex)})
        
        // Gather all results
        var allResults = [ItemRemovedResult]()
        groupRemovedResults.forEach({allResults.append($0)})
        trackRemovedResults.forEach({allResults.append($0)})
        
        // Sort by group index (descending)
        return ItemRemovedResults(allResults.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}))
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMovedResults {
        
        if (!groupsToMove.isEmpty) {
            
            return moveGroupsUp(groupsToMove)
            
        } else {
            
            // Find out which group these tracks belong to, and categorize them
            var tracksByGroup: [Group: [Int]] = [Group: [Int]]()
            var results = [ItemMovedResult]()
            
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
                return ItemMovedResults([], self.type.toPlaylistType())
            }

            tracksByGroup.forEach({
                
                let group = $0.key
                let mappings = group.moveTracksUp(IndexSet($0.value))
                for (old, new) in mappings {
                     results.append(TrackMovedResult(old, new, group))
                }
            })
            
            // Ascending order (by old index)
            return ItemMovedResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), self.type.toPlaylistType())
        }
    }
    
    private func moveGroupsUp(_ groupsToMove: [Group]) -> ItemMovedResults {
        
        var indexes = [Int]()
        groupsToMove.forEach({indexes.append(indexOfGroup($0))})
        
        // Indexes need to be in ascending order, because tracks need to be moved up, one by one, from top to bottom of the playlist
        let ascendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMovedResult]()
        
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
                results.append(GroupMovedResult(oldIndex, newIndex))
            }
        }
        
        // Ascending order (by old index)
        return ItemMovedResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), self.type.toPlaylistType())
    }
    
    private func moveGroupUp(_ index: Int) -> Int {
        
        let upIndex = index - 1
        swapGroups(index, upIndex)
        return upIndex
    }
    
    private func swapGroups(_ index1: Int, _ index2: Int) {
        swap(&groups[index1], &groups[index2])
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groupsToMove: [Group]) -> ItemMovedResults {
        
        if (!groupsToMove.isEmpty) {
            
            return moveGroupsDown(groupsToMove)
            
        } else {
            
            // Find out which group these tracks belong to, and categorize them
            var tracksByGroup: [Group: [Int]] = [Group: [Int]]()
            var results = [ItemMovedResult]()
            
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
                return ItemMovedResults([], self.type.toPlaylistType())
            }
            
            tracksByGroup.forEach({
                
                let group = $0.key
                let mappings = group.moveTracksDown(IndexSet($0.value))
                for (old, new) in mappings {
                    results.append(TrackMovedResult(old, new, group))
                }
            })
            
            // Descending order (by old index)
            return ItemMovedResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), self.type.toPlaylistType())
        }
    }
    
    private func moveGroupsDown(_ groupsToMove: [Group]) -> ItemMovedResults {
        
        var indexes = [Int]()
        groupsToMove.forEach({indexes.append(indexOfGroup($0))})
        
        // Indexes need to be in descending order, because tracks need to be moved down, one by one, from bottom to top of the playlist
        let descendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [ItemMovedResult]()
        
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
                results.append(GroupMovedResult(oldIndex, newIndex))
            }
        }
        
        // Descending order (by old index)
        return ItemMovedResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), self.type.toPlaylistType())
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
    
    func reorderTracksAndGroups(_ reorderOperations: [GroupingPlaylistReorderOperation]) {
        
        // Perform all operations in sequence
        for op in reorderOperations {
            
            // Check which kind of operation this is, and perform it
            if let removeOp = op as? GroupedTrackRemoveOperation {
                
                removeOp.group.tracks.remove(at: removeOp.index)
                
            } else if let insertOp = op as? GroupedTrackInsertOperation {
                
                insertOp.group.tracks.insert(insertOp.srcTrack, at: insertOp.destIndex)
                
            } else if let removeOp = op as? GroupRemoveOperation {
                
                groups.remove(at: removeOp.index)
                
            } else if let insertOp = op as? GroupInsertOperation {
                
                groups.insert(insertOp.srcGroup, at: insertOp.destIndex)
            }
        }
    }
}

struct ItemRemovedResults {
    
    let results: [ItemRemovedResult]
    
    init(_ results: [ItemRemovedResult]) {
        self.results = results
    }
}

protocol ItemRemovedResult {
    
    var sortIndex: Int {get}
}

struct GroupRemovedResult: ItemRemovedResult {
    
    let group: Group
    let groupIndex: Int
    
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ group: Group, _ groupIndex: Int) {
        
        self.group = group
        self.groupIndex = groupIndex
    }
}

struct TracksRemovedResult: ItemRemovedResult {
    
    let trackIndexesInGroup: IndexSet
    let parentGroup: Group
    let groupIndex: Int
    
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ trackIndexesInGroup: IndexSet, _ parentGroup: Group, _ groupIndex: Int) {
        self.trackIndexesInGroup = trackIndexesInGroup
        self.parentGroup = parentGroup
        self.groupIndex = groupIndex
    }
}

struct ItemMovedResults {
    
    let results: [ItemMovedResult]
    let playlistType: PlaylistType
    
    init(_ results: [ItemMovedResult], _ playlistType: PlaylistType) {
        self.results = results
        self.playlistType = playlistType
    }
}

protocol ItemMovedResult {
    
    var sortIndex: Int {get}
}

struct GroupMovedResult: ItemMovedResult {
    
    let oldGroupIndex: Int
    let newGroupIndex: Int
    
    var sortIndex: Int {
        return oldGroupIndex
    }
    
    init(_ oldGroupIndex: Int, _ newGroupIndex: Int) {
        
        self.oldGroupIndex = oldGroupIndex
        self.newGroupIndex = newGroupIndex
    }
}

struct TrackMovedResult: ItemMovedResult {
    
    let oldTrackIndex: Int
    let newTrackIndex: Int
    let parentGroup: Group?
    
    var sortIndex: Int {
        return oldTrackIndex
    }
    
    init(_ oldTrackIndex: Int, _ newTrackIndex: Int, _ parentGroup: Group? = nil) {
        
        self.oldTrackIndex = oldTrackIndex
        self.newTrackIndex = newTrackIndex
        self.parentGroup = parentGroup
    }
}
