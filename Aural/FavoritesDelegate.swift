import Foundation

class FavoritesDelegate: FavoritesDelegateProtocol, PersistentModelObject {
    
    private let favorites: FavoritesProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(_ favorites: FavoritesProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol, _ state: FavoritesState) {
        
        self.favorites = favorites
        self.player = player
        self.playlist = playlist
        
        state.favorites.forEach({_ = self.addFavorite($0)})
    }
    
    func addFavorite(_ track: Track) -> Favorite {
        
        let fav = favorites.addFavorite(track.file)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.addedToFavorites, track.file))
        return fav
    }
    
    func addFavorite(_ file: URL) -> Favorite {
        
        let fav = favorites.addFavorite(file)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.addedToFavorites, file))
        return fav
    }
    
    func getAllFavorites() -> [Favorite] {
        return favorites.getAllFavorites()
    }
    
    func getFavoriteWithFile(_ file: URL) -> Favorite? {
        return favorites.getFavoriteWithFile(file)
    }
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite {
        return favorites.getFavoriteAtIndex(index)
    }
    
    func deleteFavoriteAtIndex(_ index: Int) {
        
        let fav = getFavoriteAtIndex(index)
        favorites.deleteFavoriteAtIndex(index)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.removedFromFavorites, fav.file))
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        favorites.deleteFavoriteWithFile(file)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.removedFromFavorites, file))
    }
    
    func countFavorites() -> Int {
        return favorites.countFavorites()
    }
    
    func favoriteWithFileExists(_ file: URL) -> Bool {
        return favorites.favoriteWithPathExists(file.path)
    }
    
    func playFavorite(_ favorite: Favorite) {
        
        do {
            // First, find or add the given file
            let newTrack = try playlist.findOrAddFile(favorite.file)
            
            // Try playing it
            player.play(newTrack.track)
            
        } catch let error {
            
            // TODO: Handle FileNotFoundError
            if let fnfError = error as? FileNotFoundError {
                NSLog("Unable to play Favorites item. Details: %@", fnfError.message)
            }
        }
    }
    
    func persistentState() -> PersistentState {
        
        let state = FavoritesState()
        
        favorites.getAllFavorites().forEach({
            
            state.favorites.append($0.file)
        })
        return state
    }
}
