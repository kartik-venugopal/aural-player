import Foundation

// TODO: Thread-safety !
// TODO: Make this conform to GroupingAccessor
class GroupingPlaylist: GroupingPlaylistCRUDProtocol {
    
    private var type: GroupType
    private var groups: [Group] = [Group]()
    private var groupsByName: [String: Group] = [String: Group]()
    
    init(_ type: GroupType) {
        self.type = type
    }
    
    func getGroupType() -> GroupType {
        return type
    }
    
    func getNumberOfGroups() -> Int {
        return groups.count
    }
    
    func clear() {
        groups.removeAll()
        groupsByName.removeAll()
    }
    
    func sort(_ sort: Sort) {
        // TODO
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return SearchResults(results: [])
    }
    
    func addTrackForGroupInfo(_ track: Track) -> GroupedTrackAddResult {
        
        let groupName = getGroupNameForTrack(track)
        
        var group: Group?
        var groupCreated: Bool = false
        var groupIndex: Int = -1
        
        ConcurrencyUtils.executeSynchronized(groups) {
        
            group = findGroupByName(groupName)
            if (group == nil) {
                
                // Create the group
                group = Group(type, groupName)
                groups.append(group!)
                groupsByName[groupName] = group
                groupIndex = groups.count - 1
                groupCreated = true
                
            } else {
                groupIndex = groups.index(where: {$0 === group})!
            }
        }
        
        let trackIndex = group!.addTrack(track)
        let groupedTrack = GroupedTrack(track, group!, trackIndex, groupIndex)
        
        return GroupedTrackAddResult(track: groupedTrack, groupCreated: groupCreated)
    }
    
    private func getGroupNameForTrack(_ track: Track) -> String {
        
        var _groupName: String?
        
        switch self.type {
            
        case .artist: _groupName = track.groupingInfo.artist
            
        case .album: _groupName = track.groupingInfo.album
            
        case .genre: _groupName = track.groupingInfo.genre
            
        }
        
        return _groupName ?? "<Unknown>"
    }
    
    func getGroupForTrack(_ track: Track) -> Group {
        
        let name = getGroupNameForTrack(track)
        return groupsByName[name]!
    }
    
    // Returns group index
    func removeGroup(_ group: Group) -> Int {
        
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
    
    private func removeTrack(_ track: Track) -> Int {
     
        let group = getGroupForTrack(track)
        let trackIndex = group.indexOf(track)
        
        ConcurrencyUtils.executeSynchronized(groups) {
            
            _ = group.removeTrack(track)
            
            // TODO: IS this necessary ? removeTracksAndGroups will check this before calling here
            if (group.size() == 0) {
                
                groups.remove(at: groups.index(of: group)!)
                groupsByName.removeValue(forKey: group.name)
            }
        }
        
        return trackIndex
    }

    func getGroupAt(_ index: Int) -> Group {
        return groups[index]
    }

    func size() -> Int {
        return groups.count
    }
    
    func indexOf(_ track: Track) -> Int {
        return getGroupForTrack(track).indexOf(track)
    }
    
    func getIndexOf(_ group: Group) -> Int {
        return groups.index(where: {$0 === group})!
    }
    
    func displayNameFor(_ track: Track) -> String {
        
        switch self.type {
            
        case .artist:
            
            return track.displayInfo.title ?? track.conciseDisplayName
            
        case .album:
            
            return track.displayInfo.title ?? track.conciseDisplayName
            
        case .genre:
            
            return track.conciseDisplayName
        }
    }
    
    func findGroupByName(_ name: String) -> Group? {
        return groupsByName[name]
    }
    
    func removeTracks(_ tracks: [Track]) {
        _ = removeTracksAndGroups(tracks, [])
    }
    
    func removeTracksFromGroup(_ removedTracks: [Track], _ group: Group) -> IndexSet {
        
        var trackIndexes = [Int]()
        
        removedTracks.forEach({trackIndexes.append(group.indexOf($0))})
        
        trackIndexes = trackIndexes.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        
        trackIndexes.forEach({group.removeTrackAtIndex($0)})
        
        return IndexSet(trackIndexes)
    }
    
    func removeGroups(_ removedGroups: [Group]) -> IndexSet {
        
        var groupIndexes = [Int]()
        removedGroups.forEach({groupIndexes.append(groups.index(of: $0)!)})
        
        // Sort descending
        groupIndexes = groupIndexes.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        
        groupIndexes.forEach({removeGroup($0)})
        
        return IndexSet(groupIndexes)
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
        _groups.forEach({groupRemovedResults.append(GroupRemovedResult(getIndexOf($0)))})
        
        // Remove tracks from their respective groups and note the track indexes (this does not have to be done in the order of group index)
        tracksByGroup.forEach({
            
            let group = $0.key
            let trackIndexes = removeTracksFromGroup($0.value, group)
            trackRemovedResults.append(TracksRemovedResult(trackIndexes, group, getIndexOf(group)))
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
    
    func getGroupingInfoForTrack(_ track: Track) -> GroupedTrack {
        
        let group = getGroupForTrack(track)
        let groupIndex = getIndexOf(group)
        let trackIndex = group.indexOf(track)
        
        return GroupedTrack(track, group, trackIndex, groupIndex)
    }
    
    func trackInfoUpdated(_ updatedTrack: Track) {
        
        // Re-add/re-group the updated track
        ConcurrencyUtils.executeSynchronized(groups) {
            _ = removeTrack(updatedTrack)
            _ = addTrackForGroupInfo(updatedTrack)
        }
    }
    
    func getGroupIndex(_ group: Group) -> Int {
        return groups.index(of: group)!
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
    
    let groupIndex: Int
    
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ groupIndex: Int) {
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
