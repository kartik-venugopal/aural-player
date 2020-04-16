import Foundation

class FavoritesDelegate: FavoritesDelegateProtocol {
    
    private let favorites: FavoritesProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(_ favorites: FavoritesProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol, _ state: [(file: URL, name: String)]) {
        
        self.favorites = favorites
        self.player = player
        self.playlist = playlist
        
        state.forEach({_ = self.addFavorite($0.file, $0.name)})
    }
    
    func addFavorite(_ track: Track) -> Favorite {
        
        let fav = favorites.addFavorite(track.file, track.conciseDisplayName)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.addedToFavorites, track.file))
        return fav
    }
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite {
        
        let fav = favorites.addFavorite(file, name)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.addedToFavorites, file))
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
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.removedFromFavorites, fav.file))
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        favorites.deleteFavoriteWithFile(file)
        AsyncMessenger.publishMessage(FavoritesUpdatedAsyncMessage(.removedFromFavorites, file))
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
                player.play(newTrack.track)
            }
            
        } catch let error {
            
            // TODO: Handle FileNotFoundError
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play Favorites item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    var persistentState: [(URL, String)] {
        
        var arr: [(URL, String)] = []
        
        favorites.allFavorites.forEach({
            arr.append(($0.file, $0.name))
        })
        
        return arr
    }
}
