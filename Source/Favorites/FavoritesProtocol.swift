import Foundation

protocol FavoritesProtocol {
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite
    
    var allFavorites: [Favorite] {get}
    
    var count: Int {get}
    
    func getFavoriteWithFile(_ file: URL) -> Favorite?
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite
    
    func deleteFavoriteAtIndex(_ index: Int)
    
    func deleteFavoriteWithFile(_ file: URL)
    
    func favoriteWithPathExists(_ path: String) -> Bool
    
    func getFavoriteWithPath(_ path: String) -> Favorite?
    
    func deleteAllFavorites()
}
