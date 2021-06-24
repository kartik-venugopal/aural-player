//
//  FavoritesDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

private typealias Favorites = MappedPresets<Favorite>

class FavoritesDelegate: FavoritesDelegateProtocol {
    
    private let favorites: Favorites
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(persistentState: [FavoritePersistentState]?, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.player = player
        self.playlist = playlist
        
        let allFavorites = persistentState?.map {Favorite($0.file, $0.name)} ?? []
        self.favorites = Favorites(systemDefinedPresets: [], userDefinedPresets: allFavorites)
    }
    
    func addFavorite(_ track: Track) -> Favorite {
        
        let favorite = Favorite(track.file, track.displayName)
        favorites.addPreset(favorite)
        Messenger.publish(.favoritesList_trackAdded, payload: track.file)
        
        return favorite
    }
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite {
        
        let favorite = Favorite(file, name)
        favorites.addPreset(favorite)
        Messenger.publish(.favoritesList_trackAdded, payload: file)
        
        return favorite
    }
    
    var allFavorites: [Favorite] {favorites.userDefinedPresets}
    
    var count: Int {favorites.numberOfUserDefinedPresets}
    
    func getFavoriteWithFile(_ file: URL) -> Favorite? {
        favorites.userDefinedPreset(named: file.path)
    }
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite {
        favorites.userDefinedPresets[index]
    }
    
    func deleteFavoriteAtIndex(_ index: Int) {
        
        let fav = getFavoriteAtIndex(index)
        favorites.deletePreset(atIndex: index)
        Messenger.publish(.favoritesList_tracksRemoved, payload: Set([fav.file]))
    }
    
    func deleteFavorites(atIndices indices: IndexSet) {
        
        let deletedFavs = indices.map {favorites.userDefinedPresets[$0].file}
        favorites.deletePresets(atIndices: indices)
        Messenger.publish(.favoritesList_tracksRemoved, payload: Set(deletedFavs))
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        
        favorites.deletePreset(named: file.path)
        Messenger.publish(.favoritesList_tracksRemoved, payload: Set([file]))
    }
    
    func favoriteWithFileExists(_ file: URL) -> Bool {
        favorites.userDefinedPresetExists(named: file.path)
    }
    
    func playFavorite(_ favorite: Favorite) throws {
        
        do {
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(favorite.file) {
            
                // Try playing it
                player.play(newTrack)
            }
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play Favorites item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    var persistentState: [FavoritePersistentState] {
        allFavorites.map {FavoritePersistentState(file: $0.file, name: $0.name)}
    }
}
