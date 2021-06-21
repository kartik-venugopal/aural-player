import Foundation

class FavoritesDelegate: FavoritesDelegateProtocol {
    
    private let favorites: FavoritesProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(persistentState: [FavoritePersistentState]?, _ favorites: FavoritesProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.favorites = favorites
        self.player = player
        self.playlist = playlist
        
        persistentState?.forEach {_ = self.addFavorite($0.file, $0.name)}
    }
    
    func addFavorite(_ track: Track) -> Favorite {
        
        let fav = favorites.addFavorite(track.file, track.displayName)
        Messenger.publish(.favoritesList_trackAdded, payload: track.file)
        
        return fav
    }
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite {
        
        let fav = favorites.addFavorite(file, name)
        Messenger.publish(.favoritesList_trackAdded, payload: file)
        
        return fav
    }
    
    var allFavorites: [Favorite] {
        return favorites.allFavorites
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
        Messenger.publish(.favoritesList_trackRemoved, payload: fav.file)
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        
        favorites.deleteFavoriteWithFile(file)
        Messenger.publish(.favoritesList_trackRemoved, payload: file)
    }
    
    var count: Int {
        return favorites.count
    }
    
    func favoriteWithFileExists(_ file: URL) -> Bool {
        return favorites.favoriteWithPathExists(file.path)
    }
    
    func playFavorite(_ favorite: Favorite) throws {
        
        do {
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(favorite.file) {
            
                // Try playing it
                player.play(newTrack)
            }
            
        } catch let error {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play Favorites item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    var persistentState: [FavoritePersistentState] {
        favorites.allFavorites.map {FavoritePersistentState(file: $0.file, name: $0.name)}
    }
}
