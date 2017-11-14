import Cocoa
/*
    Model object that manages all historical information, in chronological order:
 
    - Recently added items: tracks, playlist files, folders
    - Recently played items: tracks
    - Favorites: tracks
 
 */
class History: HistoryProtocol {
    
    // NOTE - All history items in the 3 lists are stored in chronological order (in the LRUArray data structure), i.e. most recent items first.
 
    // Recently added items
    var recentlyAddedItems: LRUArray<AddedItem> = LRUArray<AddedItem>(25)
    
    // Recently played items
    var recentlyPlayedItems: LRUArray<PlayedItem> = LRUArray<PlayedItem>(25)
    
    // Favorites items
    var favorites: LRUArray<FavoritesItem> = LRUArray<FavoritesItem>(25)
    
    func addRecentlyAddedItems(_ items: [URL]) {
        
        var recentlyAddedItemsArr: [AddedItem] = []
        items.forEach({recentlyAddedItemsArr.append(AddedItem($0))})
        recentlyAddedItems.addAll(recentlyAddedItemsArr)
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return recentlyAddedItems.toArray().reversed()
    }
    
    func addRecentlyPlayedItem(_ item: Track) {
        recentlyPlayedItems.add(PlayedItem(item.file, item))
    }
    
    func addRecentlyPlayedItem(_ item: URL) {
        recentlyPlayedItems.add(PlayedItem(item, nil))
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return recentlyPlayedItems.toArray().reversed()
    }
    
    func hasFavorite(_ track: Track) -> Bool {
        return favorites.contains(FavoritesItem(track.file, nil))
    }
    
    func addFavorite(_ item: Track) {
        favorites.add(FavoritesItem(item.file, item))
    }
    
    func addFavorite(_ item: URL) {
        favorites.add(FavoritesItem(item, nil))
    }
    
    func removeFavorite(_ item: Track) {
        favorites.remove(FavoritesItem(item.file, item))
    }
    
    func allFavorites() -> [FavoritesItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return favorites.toArray().reversed()
    }
}
