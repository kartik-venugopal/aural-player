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
        
        return GroupedTrackAddResult(type: group!.type, track: groupedTrack, groupCreated: groupCreated)
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
    
    private func removeTrack(_ track: Track) {
     
        let group = getGroupForTrack(track)
        
        ConcurrencyUtils.executeSynchronized(groups) {
            
            _ = group.removeTrack(track)
            
            if (group.size() == 0) {
                
                groups.remove(at: groups.index(of: group)!)
                groupsByName.removeValue(forKey: group.name)
            }
        }
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
        tracks.forEach({removeTrack($0)})
    }
    
    func removeTracksAndGroups(_ request: RemoveTracksAndGroupsRequest) {
        
        request.mappings.forEach({
            
            let group = $0.group
            let groupIndex = $0.groupIndex
            let tracks = $0.tracks
            let groupRemoved = $0.groupRemoved
            
            if (groupRemoved) {
                
                removeGroup(groupIndex)
                print("Playlist: Removed group:", group.name)
                
            } else {
                
                for track in tracks! {
                    _ = removeTrack(track)
                    print("Playlist: Removed track:", track.conciseDisplayName)
                }
            }
        })
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
