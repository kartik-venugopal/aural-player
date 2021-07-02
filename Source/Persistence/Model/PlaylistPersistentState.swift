//
//  PlaylistPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
