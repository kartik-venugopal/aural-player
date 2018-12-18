import Foundation

protocol FavoritesDelegateProtocol {
    
    func addFavorite(_ track: Track) -> Favorite
    
    func addFavorite(_ file: URL, _ name: String) -> Favorite
    
    func getAllFavorites() -> [Favorite]
    
    func getFavoriteWithFile(_ file: URL) -> Favorite?
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite
    
    func deleteFavoriteAtIndex(_ index: Int)
    
    func deleteFavoriteWithFile(_ file: URL)
    
    func countFavorites() -> Int
    
    func favoriteWithFileExists(_ file: URL) -> Bool
    
    func playFavorite(_ favorite: Favorite)
}
