import Foundation

class GroupedPlaylist {
    
    var type: GroupType
    var groups: [Group] = [Group]()
    var groupsByName: [String: Group] = [String: Group]()
    
    init(_ type: GroupType, _ tracks: [Track]) {
        
        self.type = type
        groupTracks(tracks)
    }
    
    private func groupTracks(_ tracks: [Track]) {
        
        // Initialize groups from flat playlist
        var tracksByGroup: [String: [Track]] = [String: [Track]]()
        
        // TODO: Create a group for "No Artist"
        
        for track in tracks {
            
            var _groupName: String?
            
            switch self.type {
                
            case .artist:
                
                _groupName = track.groupingInfo.artist
                
            case .album:
                
                _groupName = track.groupingInfo.album
                
            case .genre:
                
                print("Genre")
                _groupName = track.groupingInfo.genre
            }
            
            if let groupName = _groupName {
                
                // If no tracks for this group yet, create an entry
                if tracksByGroup[groupName] == nil {
                    tracksByGroup[groupName] = [Track]()
                }
                
                tracksByGroup[groupName]!.append(track)
                
            } else {
                
                // If no tracks for this artist yet, create an entry
                if tracksByGroup["<Unknown>"] == nil {
                    tracksByGroup["<Unknown>"] = [Track]()
                }
                
                tracksByGroup["<Unknown>"]!.append(track)
            }
        }
        
        for (groupName, tracksForGroup) in tracksByGroup {
            
            let group = Group(type, groupName)
            group.tracks = tracksForGroup
            groups.append(group)
            group.sort()
            
            groupsByName[groupName] = group
        }
        
        if (groups.count > 0) {
            
            // Sort in ascending order by group name
            groups.sort(by: {$0.name.compare($1.name) == ComparisonResult.orderedAscending})
            
            let unknownNameGroupIndex: Int = groups.index(where: {$0.name == "<Unknown>"})!
            groups.append(groups.remove(at: unknownNameGroupIndex))
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
    
    func displayNameFor(_ track: Track) -> String {
        
        switch self.type {
            
        case .artist:
            
            return track.displayInfo.title != nil ? String(format: "%d.\t%@", track.groupingInfo.trackNumber!, track.displayInfo.title!) : track.conciseDisplayName
            
        case .album:
            
            return track.displayInfo.title != nil ? String(format: "%d.\t%@", track.groupingInfo.trackNumber!, track.displayInfo.title!) : track.conciseDisplayName
            
        case .genre:
            
            return track.conciseDisplayName
        }
    }
}
