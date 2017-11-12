import Cocoa

class History {
 
    var playedItems: LRUArray<HistoryItem> = LRUArray<HistoryItem>(25)
    var favorites: LRUArray<HistoryItem> = LRUArray<HistoryItem>(25)
    
    func addPlayedItem(_ item: Track) {
        playedItems.add(HistoryItem(item.file, item))
    }
    
    func addPlayedItem(_ item: URL) {
        playedItems.add(HistoryItem(item, nil))
    }
    
    func allPlayedItems() -> [HistoryItem] {
        return playedItems.toArray().reversed()
    }
    
    func hasFavorite(_ track: Track) -> Bool {
        return favorites.contains(HistoryItem(track.file, nil))
    }
    
    func addFavorite(_ item: Track) {
        favorites.add(HistoryItem(item.file, item))
    }
    
    func addFavorite(_ item: URL) {
        favorites.add(HistoryItem(item, nil))
    }
    
    func removeFavorite(_ item: Track) {
        favorites.remove(HistoryItem(item.file, item))
    }
    
    func allFavorites() -> [HistoryItem] {
        return favorites.toArray().reversed()
    }
}
