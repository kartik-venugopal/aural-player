//
//  FavoriteDecadesViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteDecadesViewController: FavoritesTableViewController {
    
    override var nibName: String? {"FavoriteDecades"}
    
    override var numberOfFavorites: Int {
        favoritesDelegate.numberOfFavoriteDecades
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favoritesDelegate.favoriteDecade(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgDecadeGroup
    }
}
