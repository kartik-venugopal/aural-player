//
//  FavoritesProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
protocol FavoritesProtocol: TrackInitComponent {
    
//    func initialize(fromPersistentState persistentState: FavoritesPersistentState?)
    
    func addFavorite(track: Track)
    
//    func addFavorite(artist: String)
//
//    func addFavorite(album: String)
//
//    func addFavorite(genre: String)
//    
//    func addFavorite(decade: String)
    
    func addFavorite(folder: URL)
    
    func addFavorite(playlistFile: URL)
    
    func removeFavorite(_ favorite: Favorite)
    
    func removeFavorite(track: Track)
    
//    func removeFavorite(artist: String)
//
//    func removeFavorite(album: String)
//
//    func removeFavorite(genre: String)
//    
//    func removeFavorite(decade: String)
    
    func removeFavorite(folder: URL)
    
    func removeFavorite(playlistFile: URL)
    
    var hasAnyFavorites: Bool {get}
    
    var allFavoriteTracks: [FavoriteTrack] {get}
    var numberOfFavoriteTracks: Int {get}
    func favoriteTrack(atChronologicalIndex index: Int) -> FavoriteTrack?
    
    // TODO: [?] or not ?
    var artistsFromFavoriteTracks: Set<String> {get}
    var albumsFromFavoriteTracks: Set<String> {get}
    var genresFromFavoriteTracks: Set<String> {get}
    var decadesFromFavoriteTracks: Set<String> {get}
    
//    var allFavoriteArtists: [FavoriteGroup] {get}
//    var numberOfFavoriteArtists: Int {get}
//    func favoriteArtist(atChronologicalIndex index: Int) -> FavoriteGroup?
//    
//    var allFavoriteAlbums: [FavoriteGroup] {get}
//    var numberOfFavoriteAlbums: Int {get}
//    func favoriteAlbum(atChronologicalIndex index: Int) -> FavoriteGroup?
//    
//    var allFavoriteGenres: [FavoriteGroup] {get}
//    var numberOfFavoriteGenres: Int {get}
//    func favoriteGenre(atChronologicalIndex index: Int) -> FavoriteGroup?
//    
//    var allFavoriteDecades: [FavoriteGroup] {get}
//    var numberOfFavoriteDecades: Int {get}
//    func favoriteDecade(atChronologicalIndex index: Int) -> FavoriteGroup?
    
    var allFavoriteFolders: [FavoriteFolder] {get}
    var numberOfFavoriteFolders: Int {get}
    func favoriteFolder(atChronologicalIndex index: Int) -> FavoriteFolder?
    
    var allFavoritePlaylistFiles: [FavoritePlaylistFile] {get}
    var numberOfFavoritePlaylistFiles: Int {get}
    func favoritePlaylistFile(atChronologicalIndex index: Int) -> FavoritePlaylistFile?
    
    func favoriteExists(track: Track) -> Bool
    
//    func favoriteExists(artist: String) -> Bool
//    
//    func favoriteExists(album: String) -> Bool
//    
//    func favoriteExists(genre: String) -> Bool
//    
//    func favoriteExists(decade: String) -> Bool
    
    func favoriteExists(playlistFile: URL) -> Bool
    
    func favoriteExists(folder: URL) -> Bool
    
    func playFavorite(_ favorite: Favorite)
    
//    func enqueueFavorite(_ favorite: Favorite)
}
