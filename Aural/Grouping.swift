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
    
    private func addTrack(_ track: Track) {
        
//        print("Adding: ", track.conciseDisplayName)
        
        let groupName = getGroupNameForTrack(track)
        
        var group: Group?
        
        ConcurrencyUtils.executeSynchronized(groups) {
        
            group = findGroupByName(groupName)
            if (group == nil) {
                group = Group(type, groupName)
                groups.append(group!)
                groupsByName[groupName] = group
                NSLog("Created group: %@", groupName)
            }
        }
        
        group!.addTrack(track)
//        print("Added", track.conciseDisplayName, "to:", group!.name)
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
    
    func getGroupForTrack(_ track: Track) -> Group? {
        
        let name = getGroupNameForTrack(track)
        let group = groupsByName[name]
//        print("REturning", group?.name, "for", track.conciseDisplayName)
        NSLog("Returning group: %@ for track: %@", name, track.conciseDisplayName)
        return group
    }
    
    func removeTrack(_ track: Track) {
        
        for group in groups {
            
            if group.tracks.contains(track) {
                
                ConcurrencyUtils.executeSynchronized(groups) {
                    
                    group.removeTrack(track)
//                    print("Removed", track.conciseDisplayName, "from:", group.name)
                    
                    if (group.size() == 0) {
                        
//                        print("Empty group:", group.name)
                        
                        if let index = groups.index(where: {$0 === group}) {
                            groups.remove(at: index)
                            groupsByName.removeValue(forKey: group.name)
                            print("\tRemoved group:", group.name, "at:", index)
                        }
                    }
                }
                
                return
            }
        }
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
