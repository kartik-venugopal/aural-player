//
//  FavoriteGenresViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteGenresViewController: FavoritesTableViewController {
    
    override var nibName: NSNib.Name? {"FavoriteGenres"}
    
    override var numberOfFavorites: Int {
        favoritesDelegate.numberOfFavoriteGenres
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favoritesDelegate.favoriteGenre(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgGenreGroup
    }
}
