//
//  FavoritePlaylistFilesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoritePlaylistFilesViewController: FavoritesTableViewController {
    
    override var nibName: NSNib.Name? {"FavoritePlaylistFiles"}
    
    override var numberOfFavorites: Int {
        favorites.numberOfFavoritePlaylistFiles
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favorites.favoritePlaylistFile(atChronologicalIndex: row)?.name
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgPlaylist
    }
}

