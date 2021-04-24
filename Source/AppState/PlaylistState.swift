import Foundation

/*
 Encapsulates playlist state
 */
class PlaylistState: PersistentStateProtocol {
    
    // List of track files
    var tracks: [URL]?
    var groupingPlaylists: [String: GroupingPlaylistState]?
    
    init(tracks: [URL], groupingPlaylists: [String : GroupingPlaylistState]?) {
        
        self.tracks = tracks
        self.groupingPlaylists = groupingPlaylists
    }
    
    required init?(_ map: NSDictionary) {
        
        self.tracks = map.urlArrayValue(forKey: "tracks")
        
        if let groupingPlaylistsMap = map["groupingPlaylists"] as? NSDictionary {
            
            self.groupingPlaylists = [:]
            
            if let artistsPlaylist = groupingPlaylistsMap.objectValue(forKey: "artists", ofType: GroupingPlaylistState.self) {
                
                artistsPlaylist._transient_type = "artists"
                self.groupingPlaylists?["artists"] = artistsPlaylist
            }
            
            if let albumsPlaylist = groupingPlaylistsMap.objectValue(forKey: "albums", ofType: GroupingPlaylistState.self) {
                
                albumsPlaylist._transient_type = "albums"
                self.groupingPlaylists?["albums"] = albumsPlaylist
            }
            
            if let genresPlaylist = groupingPlaylistsMap.objectValue(forKey: "genres", ofType: GroupingPlaylistState.self) {
                
                genresPlaylist._transient_type = "genres"
                self.groupingPlaylists?["genres"] = genresPlaylist
            }
        }
    }
}

class GroupingPlaylistState: PersistentStateProtocol {
    
    var _transient_type: String = ""
    let groups: [GroupState]?
    
    init(_transient_type: String, groups: [GroupState]) {
        
        self._transient_type = _transient_type
        self.groups = groups
    }
    
    required init?(_ map: NSDictionary) {
        self.groups = map.arrayValue(forKey: "groups", ofType: GroupState.self)
    }
}

class GroupState: PersistentStateProtocol {
    
    let name: String

    // List of track files
    let tracks: [URL]
    
    init(name: String, tracks: [URL]) {
        
        self.name = name
        self.tracks = tracks
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let tracks = map.urlArrayValue(forKey: "tracks") else {return nil}
        
        self.name = name
        self.tracks = tracks
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PlaylistState {
        
        var groupingPlaylists: [String: GroupingPlaylistState] = [:]
        
        for (type, playlist) in self.groupingPlaylists {
            groupingPlaylists[type.rawValue] = (playlist as! GroupingPlaylist).persistentState
        }
        
        return PlaylistState(tracks: self.tracks.map {$0.file}, groupingPlaylists: groupingPlaylists)
    }
}

extension GroupingPlaylist: PersistentModelObject {
    
    var persistentState: GroupingPlaylistState {
        GroupingPlaylistState(_transient_type: self.playlistType.rawValue, groups: self.groups.map {$0.persistentState})
    }
}

extension Group: PersistentModelObject {
    
    var persistentState: GroupState {
        GroupState(name: self.name, tracks: self.tracks.map {$0.file})
    }
}
