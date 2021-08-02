//
//  PlaylistsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Manages the collection of all playlists - the default playlist and all user-defined playlists (if any).
///
class PlaylistsManager: UserManagedObjects<Playlist>, PersistentModelObject {
    
    let systemPlaylist: Playlist
    var currentPlaylist: Playlist
    
    init(systemPlaylist: Playlist, userPlaylists: [Playlist]) {
        
        self.systemPlaylist = systemPlaylist
        self.currentPlaylist = systemPlaylist
        
        super.init(systemDefinedObjects: [systemPlaylist], userDefinedObjects: userPlaylists)
    }
    
    func createNewPlaylist(named name: String) {
        
        let playlist = Playlist(name: name, userDefined: true, FlatPlaylist(),
                                [GroupingPlaylist(.artists), GroupingPlaylist(.albums), GroupingPlaylist(.genres)])
        
        addObject(playlist)
    }
    
    var persistentState: PlaylistsPersistentState {
        
        let systemPlaylistState = systemPlaylist.persistentState
        
        return PlaylistsPersistentState(tracks: systemPlaylistState.tracks,
                                 groupingPlaylists: systemPlaylistState.groupingPlaylists,
                                 userPlaylists: userDefinedObjects.map {$0.persistentState})
    }
}
