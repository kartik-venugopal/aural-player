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

///
/// A delegate allowing access to the list of user-defined favorites.
///
/// Acts as a middleman between the UI and the Favorites list,
/// providing a simplified interface / facade for the UI layer to manipulate the Favorites list.
///
/// - SeeAlso: `Favorite`
///
class FavoritesDelegate: FavoritesDelegateProtocol {
    
    private typealias Favorites = UserManagedObjects<Favorite>
    
    private let favorites: Favorites
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: [FavoritePersistentState]?, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.player = player
        self.playlist = playlist
        
        let allFavorites = persistentState?.compactMap {Favorite(persistentState: $0)} ?? []
        self.favorites = Favorites(systemDefinedObjects: [], userDefinedObjects: allFavorites)
    }
    
    func addFavorite(_ track: Track) -> Favorite {
        
        let favorite = Favorite(track.file, track.displayName)
        favorites.addObject(favorite)
        messenger.publish(.favoritesList_trackAdded, payload: favorite)
        
        return favorite
    }
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite {
        
        let favorite = Favorite(file, name)
        favorites.addObject(favorite)
        messenger.publish(.favoritesList_trackAdded, payload: favorite)
        
        return favorite
    }
    
    var allFavorites: [Favorite] {favorites.userDefinedObjects}
    
    var count: Int {favorites.numberOfUserDefinedObjects}
    
    func getFavoriteWithFile(_ file: URL) -> Favorite? {
        favorites.userDefinedObject(named: file.path)
    }
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite {
        favorites.userDefinedObjects[index]
    }
    
    func deleteFavorites(atIndices indices: IndexSet) {
        
        let deletedFavorites = favorites.deleteObjects(atIndices: indices)
        messenger.publish(.favoritesList_tracksRemoved, payload: Set(deletedFavorites))
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        
        if let favorite = favorites.deleteObject(named: file.path) {
            messenger.publish(.favoritesList_tracksRemoved, payload: Set([favorite]))
        }
    }
    
    func favoriteWithFileExists(_ file: URL) -> Bool {
        favorites.userDefinedObjectExists(named: file.path)
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
        allFavorites.map {FavoritePersistentState(favorite: $0)}
    }
}
