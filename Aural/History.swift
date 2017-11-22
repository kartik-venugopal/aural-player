import Cocoa

/*
    Model object that manages all historical information, in chronological order:
 
    - Recently added items: tracks, playlist files, folders
    - Recently played items: tracks
    - Favorites: tracks
 
 */
class History: HistoryProtocol {
    
    // Recently added items
    var recentlyAddedItems: LRUArray<AddedItem>
    
    // Recently played items
    var recentlyPlayedItems: LRUArray<PlayedItem>
    
    // Favorites items
    var favorites: LRUArray<FavoritesItem>
    
    init(_ preferences: HistoryPreferences) {
        
        recentlyAddedItems = LRUArray<AddedItem>(preferences.recentlyAddedListSize)
        recentlyPlayedItems = LRUArray<PlayedItem>(preferences.recentlyPlayedListSize)
        favorites = LRUArray<FavoritesItem>(preferences.favoritesListSize)
    }
    
    func addRecentlyAddedItems(_ items: [(file: URL, time: Date)]) {
        
        var recentlyAddedItemsArr: [AddedItem] = []
        items.forEach({recentlyAddedItemsArr.append(AddedItem($0.file, $0.time))})
        recentlyAddedItems.addAll(recentlyAddedItemsArr)
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return recentlyAddedItems.toArray().reversed()
    }
    
    func addRecentlyPlayedItem(_ item: Track, _ time: Date) {
        recentlyPlayedItems.add(PlayedItem(item.file, time, item))
    }
    
    func addRecentlyPlayedItem(_ file: URL, _ time: Date) {
        recentlyPlayedItems.add(PlayedItem(file, time, nil))
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return recentlyPlayedItems.toArray().reversed()
    }
    
    func hasFavorite(_ track: Track) -> Bool {
        return favorites.contains(FavoritesItem(track.file, Date(), nil))
    }
    
    func addFavorite(_ item: Track, _ time: Date) {
        favorites.add(FavoritesItem(item.file, time, item))
    }
    
    func addFavorite(_ file: URL, _ time: Date) {
        favorites.add(FavoritesItem(file, time, nil))
    }
    
    func removeFavorite(_ item: Track) {
        favorites.remove(FavoritesItem(item.file, Date(), item))
    }
    
    func allFavorites() -> [FavoritesItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return favorites.toArray().reversed()
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int, _ favoritesListSize: Int) {
        
        recentlyAddedItems.resize(recentlyAddedListSize)
        recentlyPlayedItems.resize(recentlyPlayedListSize)
        favorites.resize(favoritesListSize)
    }
}
