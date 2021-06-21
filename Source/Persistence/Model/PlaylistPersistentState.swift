import Foundation

/*
 Encapsulates playlist state
 */
class PlaylistPersistentState: PersistentStateProtocol {
    
    // List of track files
    var tracks: [URL]?
    var groupingPlaylists: [String: GroupingPlaylistPersistentState]?
    
    init(tracks: [URL], groupingPlaylists: [String : GroupingPlaylistPersistentState]?) {
        
        self.tracks = tracks
        self.groupingPlaylists = groupingPlaylists
    }
    
    required init?(_ map: NSDictionary) {
        
        self.tracks = map.urlArrayValue(forKey: "tracks")
        
        if let groupingPlaylistsMap = map["groupingPlaylists", NSDictionary.self] {
            
            self.groupingPlaylists = [:]
            
            if let artistsPlaylist = groupingPlaylistsMap.persistentObjectValue(forKey: "artists", ofType: GroupingPlaylistPersistentState.self) {
                self.groupingPlaylists?["artists"] = artistsPlaylist
            }
            
            if let albumsPlaylist = groupingPlaylistsMap.persistentObjectValue(forKey: "albums", ofType: GroupingPlaylistPersistentState.self) {
                self.groupingPlaylists?["albums"] = albumsPlaylist
            }
            
            if let genresPlaylist = groupingPlaylistsMap.persistentObjectValue(forKey: "genres", ofType: GroupingPlaylistPersistentState.self) {
                self.groupingPlaylists?["genres"] = genresPlaylist
            }
        }
    }
}

class GroupingPlaylistPersistentState: PersistentStateProtocol {
    
    let type: String
    let groups: [GroupPersistentState]?
    
    init(type: String, groups: [GroupPersistentState]) {
        
        self.type = type
        self.groups = groups
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let type = map.nonEmptyStringValue(forKey: "type") else {return nil}
        
        self.type = type
        self.groups = map.persistentObjectArrayValue(forKey: "groups", ofType: GroupPersistentState.self)
    }
}

class GroupPersistentState: PersistentStateProtocol {
    
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
    var persistentState: PlaylistPersistentState {
        
        var groupingPlaylists: [String: GroupingPlaylistPersistentState] = [:]
        
        for (type, playlist) in self.groupingPlaylists {
            groupingPlaylists[type.rawValue] = (playlist as! GroupingPlaylist).persistentState
        }
        
        return PlaylistPersistentState(tracks: self.tracks.map {$0.file}, groupingPlaylists: groupingPlaylists)
    }
}

extension GroupingPlaylist: PersistentModelObject {
    
    var persistentState: GroupingPlaylistPersistentState {
        GroupingPlaylistPersistentState(type: self.playlistType.rawValue, groups: self.groups.map {$0.persistentState})
    }
}

extension Group: PersistentModelObject {
    
    var persistentState: GroupPersistentState {
        GroupPersistentState(name: self.name, tracks: self.tracks.map {$0.file})
    }
}
