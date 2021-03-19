import Foundation

/*
 Encapsulates playlist state
 */
class PlaylistState: PersistentState {
    
    // List of track files
    var tracks: [URL] = [URL]()
    var groupingPlaylists: [String: GroupingPlaylistState] = [:]
    
    init() {}
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistState()
        
        (map["tracks"] as? [String])?.forEach({state.tracks.append(URL(fileURLWithPath: $0))})
        
        if let groupingPlaylistsMap = map["groupingPlaylists"] as? NSDictionary {
         
            if let artistsPlaylistMap = groupingPlaylistsMap["artists"] as? NSDictionary, let artistsPlaylist = GroupingPlaylistState.deserialize(artistsPlaylistMap) as? GroupingPlaylistState {
                
                artistsPlaylist._transient_type = "artists"
                state.groupingPlaylists["artists"] = artistsPlaylist
            }
            
            if let albumsPlaylistMap = groupingPlaylistsMap["albums"] as? NSDictionary, let albumsPlaylist = GroupingPlaylistState.deserialize(albumsPlaylistMap) as? GroupingPlaylistState {
                
                albumsPlaylist._transient_type = "albums"
                state.groupingPlaylists["albums"] = albumsPlaylist
            }
            
            if let genresPlaylistMap = groupingPlaylistsMap["genres"] as? NSDictionary, let genresPlaylist = GroupingPlaylistState.deserialize(genresPlaylistMap) as? GroupingPlaylistState {
                
                genresPlaylist._transient_type = "genres"
                state.groupingPlaylists["genres"] = genresPlaylist
            }
        }
        
        return state
    }
}

class GroupingPlaylistState: PersistentState {
    
    var _transient_type: String = ""
    var groups: [GroupState] = []
    
    init() {}
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = GroupingPlaylistState()
        
        if let groupsArr = map["groups"] as? [NSDictionary] {
            state.groups = groupsArr.compactMap {GroupState.deserialize($0) as? GroupState}
        }
        
        return state
    }
}

class GroupState: PersistentState {
    
    var name: String = ""

    // List of track files
    var tracks: [URL] = [URL]()
    
    init() {}
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = GroupState()
        
        state.name = map["name"] as? String ?? "<Unknown>"
        
        if let trackPaths = map["tracks"] as? [String] {
            state.tracks = trackPaths.map {URL(fileURLWithPath: $0)}
        }
        
        return state
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PersistentState {
        
        let state = PlaylistState()
        
        state.tracks = tracks.map {$0.file}
        
        for (type, playlist) in self.groupingPlaylists {
            state.groupingPlaylists[type.rawValue] = ((playlist as! GroupingPlaylist).persistentState as! GroupingPlaylistState)
        }
        
        return state
    }
}

extension GroupingPlaylist: PersistentModelObject {
    
    var persistentState: PersistentState {
        
        let state = GroupingPlaylistState()
        
        state._transient_type = self.playlistType.rawValue
        state.groups = self.groups.compactMap {$0.persistentState as? GroupState}
        
        return state
    }
}

extension Group: PersistentModelObject {
    
    var persistentState: PersistentState {
        
        let state = GroupState()
        
        state.name = self.name
        state.tracks = self.tracks.map {$0.file}
        
        return state
    }
}
