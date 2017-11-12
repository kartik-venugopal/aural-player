import Cocoa

class History {
 
    var addedItems: LRUArray<AddedItem> = LRUArray<AddedItem>(25)
    var playedItems: LRUArray<PlayedItem> = LRUArray<PlayedItem>(25)
    var favorites: LRUArray<FavoritesItem> = LRUArray<FavoritesItem>(25)
    
    func addAddedItems(_ items: [URL]) {
        
        var addedItemsArr: [AddedItem] = []
        items.forEach({addedItemsArr.append(AddedItem($0))})
        addedItems.addAll(addedItemsArr)
    }
    
    func allAddedItems() -> [AddedItem] {
        return addedItems.toArray().reversed()
    }
    
    func addPlayedItem(_ item: Track) {
        playedItems.add(PlayedItem(item.file, item))
    }
    
    func addPlayedItem(_ item: URL) {
        playedItems.add(PlayedItem(item, nil))
    }
    
    func allPlayedItems() -> [PlayedItem] {
        return playedItems.toArray().reversed()
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
        return favorites.toArray().reversed()
    }
}
