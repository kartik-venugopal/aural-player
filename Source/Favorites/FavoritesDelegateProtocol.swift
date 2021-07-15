//
//  FavoritesDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate allowing access to the list of user-defined favorites.
///
/// Acts as a middleman between the UI and the Favorites list,
/// providing a simplified interface / facade for the UI layer to manipulate the Favorites list.
///
/// - SeeAlso: `Favorite`
///
protocol FavoritesDelegateProtocol {
    
    func addFavorite(_ track: Track) -> Favorite
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite
    
    var allFavorites: [Favorite] {get}
    
    var count: Int {get}
    
    func getFavoriteWithFile(_ file: URL) -> Favorite?
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite
    
    func deleteFavoriteAtIndex(_ index: Int)
    
    func deleteFavorites(atIndices indices: IndexSet)
    
    func deleteFavoriteWithFile(_ file: URL)
    
    func favoriteWithFileExists(_ file: URL) -> Bool
    
    func playFavorite(_ favorite: Favorite) throws
}
