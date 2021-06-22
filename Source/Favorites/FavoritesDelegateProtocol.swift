import Foundation

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
