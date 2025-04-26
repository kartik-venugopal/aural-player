//
//  FavoriteDecadesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteDecadesViewController: FavoritesTableViewController {
    
    override var nibName: NSNib.Name? {"FavoriteDecades"}
    
    override var numberOfFavorites: Int {
        favorites.numberOfFavoriteDecades
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favorites.favoriteDecade(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgDecadeGroup
    }
}
