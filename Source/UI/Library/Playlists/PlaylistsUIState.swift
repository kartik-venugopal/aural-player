//
//  PlaylistsUIState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class PlaylistsUIState {
    
    var selectedPlaylistIndices: IndexSet = IndexSet([])
    
    var selectedPlaylists: [Playlist] {
        selectedPlaylistIndices.compactMap {playlistsManager.userDefinedObjects[$0]}
    }
    
    var displayedPlaylist: Playlist? {
        selectedPlaylistIndices.count == 1 ? selectedPlaylists.first : nil
    }
    
    var isDisplayingAPlaylist: Bool {
        selectedPlaylistIndices.count == 1
    }
}
