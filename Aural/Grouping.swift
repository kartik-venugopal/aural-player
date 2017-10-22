import Foundation

// TODO: Thread-safety !
// TODO: Make this conform to GroupingAccessor
class Grouping: PlaylistChangeListener, TrackInfoChangeListener {
    
    var type: GroupType
    var groups: [Group] = [Group]()
    var groupsByName: [String: Group] = [String: Group]()
    
    init(_ type: GroupType) {
        self.type = type
    }
    
    func addTrack(_ track: Track) -> (group: Group, groupIndex: Int, groupIsNew: Bool) {
        
//        print("Adding: ", track.conciseDisplayName)
        
        let groupName = getGroupNameForTrack(track)
        
        var group: Group?
        var groupIsNew: Bool = false
        var groupIndex: Int = -1
        
        ConcurrencyUtils.executeSynchronized(groups) {
        
            group = findGroupByName(groupName)
            if (group == nil) {
                group = Group(type, groupName)
                groups.append(group!)
                groupsByName[groupName] = group
                groupIndex = groups.count - 1
                groupIsNew = true
//                NSLog("Created group: %@", groupName)
            } else {
                groupIndex = groups.index(where: {$0 === group})!
            }
        }
        
        group!.addTrack(track)
        
        return (group!, groupIndex, groupIsNew)
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
    
    func removeTracks(_ tracks: [Track]) -> [(group: Group, groupIndex: Int, trackIndexInGroup: Int, groupWasRemoved: Bool)] {
        
        // Sort by index within respective group
        // TODO: Send this index info from the view layer
        let sortedTracks = tracks.sorted(by: {indexOf($0) > indexOf($1)})
        
        var results = [(group: Group, groupIndex: Int, trackIndexInGroup: Int, groupWasRemoved: Bool)]()
        
        for track in sortedTracks {
            
            print("Removing from grouping: ", track.conciseDisplayName)
            results.append(removeTrack(track))
        }
        
        return results
    }
    
    func removeTrack(_ track: Track) -> (group: Group, groupIndex: Int, trackIndexInGroup: Int, groupWasRemoved: Bool) {
        
        var groupIndex: Int = -1
        var groupWasRemoved: Bool = false
        var trackIndexInGroup: Int = -1
        
        let group = getGroupForTrack(track)
        
        ConcurrencyUtils.executeSynchronized(groups) {
            
            groupIndex = groups.index(of: group)!
            trackIndexInGroup = group.removeTrack(track)
            
            if (group.size() == 0) {
                groups.remove(at: groupIndex)
                groupsByName.removeValue(forKey: group.name)
                groupWasRemoved = true
            }
        }
        
        return (group, groupIndex, trackIndexInGroup, groupWasRemoved)
    }

    func getGroup(_ index: Int) -> Group? {
        
        return index >= 0 && index < groups.count ? groups[index] : nil
    }

    func size() -> Int {
        return groups.count
    }
    
    func indexOf(_ track: Track) -> Int {
        
        switch self.type {
            
        case .artist:
            
            let artist = track.groupingInfo.artist ?? "<Unknown>"
            return groupsByName[artist]!.indexOf(track)
            
        case .album:
            
            let album = track.groupingInfo.album ?? "<Unknown>"
            return groupsByName[album]!.indexOf(track)
            
        case .genre:
            
            let genre = track.groupingInfo.genre ?? "<Unknown>"
            return groupsByName[genre]!.indexOf(track)
        }
    }
    
    func indexOf(_ group: Group) -> Int {
        
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
    
    func trackAdded(_ track: Track) {
        addTrack(track)
    }
    
    func tracksRemoved(_ removedTrackIndexes: [Int], _ removedTracks: [Track]) {
        for t in removedTracks {
            removeTrack(t)
        }
    }
    
    func trackReordered(_ oldIndex: Int, _ newIndex: Int) {
    }
    
    func playlistReordered(_ newCursor: Int?) {
    }
    
    func playlistCleared() {
        groups.removeAll()
        groupsByName.removeAll()
    }
    
    func getGroupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> (group: Group, groupIndex: Int, trackIndex: Int) {
        return (Group(.artist, ""), 1, 1)
    }
    
    func trackInfoUpdated(_ updatedTrack: Track) {
        ConcurrencyUtils.executeSynchronized(groups) {
            removeTrack(updatedTrack)
            addTrack(updatedTrack)
        }
    }
    
    func sort() {
        
        //        if (groups.count > 1) {
        //
        //            // Sort in ascending order by group name
        //            groups.sort(by: {$0.name.compare($1.name) == ComparisonResult.orderedAscending})
        //
        //            if let unknownNameGroupIndex: Int = groups.index(where: {$0.name == "<Unknown>"}) {
        //                if (unknownNameGroupIndex != groups.count - 1) {
        //                    groups.append(groups.remove(at: unknownNameGroupIndex))
        //                }
        //            }
        //        }
    }
}
