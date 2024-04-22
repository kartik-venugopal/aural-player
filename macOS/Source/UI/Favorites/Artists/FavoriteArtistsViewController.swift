//
//  FavoriteArtistsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteArtistsViewController: FavoritesTableViewController {
    
    override var nibName: String? {"FavoriteArtists"}
    
    override var numberOfFavorites: Int {
        favoritesDelegate.numberOfFavoriteArtists
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favoritesDelegate.favoriteArtist(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgArtistGroup
    }
}
