import Foundation

class Favorites: FavoritesProtocol {
    
    private var favorites: StringKeyedCollection<Favorite> = StringKeyedCollection<Favorite>()
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite {
        
        let favorite = Favorite(file, name)
        favorites.addItem(favorite)
        return favorite
    }
    
    var allFavorites: [Favorite] {
        return favorites.allItems
    }
    
    func favoriteWithPathExists(_ path: String) -> Bool {
        return favorites.itemWithKeyExists(path)
    }
    
    func getFavoriteWithFile(_ file: URL) -> Favorite? {
        return favorites.itemWithKey(file.path)
    }
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite {
        return favorites.itemAtIndex(index)
    }
    
    var count: Int {
        return favorites.count
    }
    
    func getFavoriteWithPath(_ path: String) -> Favorite? {
        return favorites.itemWithKey(path)
    }
    
    func deleteAllFavorites() {
        favorites.removeAllItems()
    }
    
    func deleteFavoriteAtIndex(_ index: Int) {
        favorites.removeItemAtIndex(index)
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        favorites.removeItemWithKey(file.path)
    }
}
